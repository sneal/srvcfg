package net.sneal.srvcfg;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@SpringBootApplication
@EnableWebMvc
public class SrvcfgApplication {

	public static void main(String[] args) {
		SpringApplication.run(SrvcfgApplication.class, args);
	}
}
