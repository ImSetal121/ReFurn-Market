package org.charno.start;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = { "org.charno" })
@MapperScan(basePackages = { "org.charno.**.mapper" })
public class BackendStartApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendStartApplication.class, args);
    }

}
