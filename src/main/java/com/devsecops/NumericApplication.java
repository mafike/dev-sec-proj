package com.devsecops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.devsecops"})
public class NumericApplication {

	
	public static void main(String[] args) {
		SpringApplication.run(NumericApplication.class, args);
	}

}