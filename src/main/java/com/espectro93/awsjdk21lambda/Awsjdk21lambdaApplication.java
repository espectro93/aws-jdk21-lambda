package com.espectro93.awsjdk21lambda;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.function.Function;

@SpringBootApplication
public class Awsjdk21lambdaApplication {

    public static void main(String[] args) {
        SpringApplication.run(Awsjdk21lambdaApplication.class, args);
    }

    @Bean
    public Function<String, String> uppercase() {
        return String::toUpperCase;
    }

}
