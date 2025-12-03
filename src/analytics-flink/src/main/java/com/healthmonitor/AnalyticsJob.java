package com.healthmonitor;

import java.util.Properties;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.functions.AggregateFunction;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.windowing.ProcessWindowFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.util.Collector;

public class AnalyticsJob {

    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        ParameterTool params = ParameterTool.fromArgs(args);
        String bootstrapServers = params.get("bootstrap.servers");
        String apiKey = params.get("api.key");
        String apiSecret = params.get("api.secret");

        if (bootstrapServers == null || apiKey == null || apiSecret == null) {
            System.out.println("Usage: --bootstrap.servers <url> --api.key <key> --api.secret <secret>");
            return;
        }

        String jaasConfig = String.format(
            "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"%s\" password=\"%s\";",
            apiKey, apiSecret
        );

        KafkaSource<String> source = KafkaSource.<String>builder()
                .setBootstrapServers(bootstrapServers)
                .setTopics("raw-vitals")
                .setGroupId("flink-analytics-group")
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new SimpleStringSchema())
                .setProperty("security.protocol", "SASL_SSL")
                .setProperty("sasl.mechanism", "PLAIN")
                .setProperty("sasl.jaas.config", jaasConfig)
                .build();

        Properties sinkProperties = new Properties();
        sinkProperties.setProperty("security.protocol", "SASL_SSL");
        sinkProperties.setProperty("sasl.mechanism", "PLAIN");
        sinkProperties.setProperty("sasl.jaas.config", jaasConfig);

        KafkaSink<String> sink = KafkaSink.<String>builder()
                .setBootstrapServers(bootstrapServers)
                .setRecordSerializer(KafkaRecordSerializationSchema.builder()
                        .setTopic("aggregated-stats")
                        .setValueSerializationSchema(new SimpleStringSchema())
                        .build()
                )
                .setKafkaProducerConfig(sinkProperties)
                .build();

        DataStream<String> kafkaStream = env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka Source");

        DataStream<String> aggregatedStream = kafkaStream
                .map(new JsonToVital())
                .keyBy(new PatientIdSelector())
                .window(TumblingProcessingTimeWindows.of(Time.minutes(1)))
                .aggregate(new AverageHeartRate(), new EnrichedResultFunction());

        aggregatedStream.sinkTo(sink);
        aggregatedStream.print();

        env.execute("Flink Vitals Analytics Job");
    }

    public static class JsonToVital implements MapFunction<String, JsonNode> {
        private static final ObjectMapper objectMapper = new ObjectMapper();
        @Override
        public JsonNode map(String value) throws Exception {
            return objectMapper.readTree(value);
        }
    }
    
    public static class PatientIdSelector implements KeySelector<JsonNode, String> {
        @Override
        public String getKey(JsonNode value) throws Exception {
            return value.get("patient_id").asText();
        }
    }

    public static class AverageHeartRate implements AggregateFunction<JsonNode, Tuple2<Long, Long>, Double> {
        @Override
        public Tuple2<Long, Long> createAccumulator() {
            return new Tuple2<>(0L, 0L);
        }

        @Override
        public Tuple2<Long, Long> add(JsonNode value, Tuple2<Long, Long> accumulator) {
            long heartRate = value.get("heart_rate").asLong();
            return new Tuple2<>(accumulator.f0 + heartRate, accumulator.f1 + 1L);
        }

        @Override
        public Double getResult(Tuple2<Long, Long> accumulator) {
            if (accumulator.f1 == 0) {
                return 0.0;
            }
            return ((double) accumulator.f0) / accumulator.f1;
        }

        @Override
        public Tuple2<Long, Long> merge(Tuple2<Long, Long> a, Tuple2<Long, Long> b) {
            return new Tuple2<>(a.f0 + b.f0, a.f1 + b.f1);
        }
    }

    public static class EnrichedResultFunction extends ProcessWindowFunction<Double, String, String, TimeWindow> {
        private static final ObjectMapper objectMapper = new ObjectMapper();

        @Override
        public void process(String key, Context context, Iterable<Double> elements, Collector<String> out) throws Exception {
            Double average = elements.iterator().next();
            ObjectNode node = objectMapper.createObjectNode();
            node.put("patient_id", key);
            node.put("avg_rate", average);
            node.put("window_end", context.window().getEnd());
            out.collect(node.toString());
        }
    }
}