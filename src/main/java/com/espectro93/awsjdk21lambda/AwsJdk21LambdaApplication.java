package com.espectro93.awsjdk21lambda;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.Base64;
import java.util.function.Function;

@SpringBootApplication
public class AwsJdk21LambdaApplication {

    public static void main(String[] args) {
        SpringApplication.run(AwsJdk21LambdaApplication.class, args);
    }

    @Bean
    public Function<String, String> obfuscate() {
        return str -> Base64.getEncoder().encodeToString(str.getBytes());
    }

}
