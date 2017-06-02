package net.sneal.srvcfg;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DefaultController {
    @Value("${foo}")
    private String foo;

    @Value("${fooSecret}")
    private String fooSecret;

    @RequestMapping("/foo")
    public String foo() {
        return "foo: " + foo;
    }

    @RequestMapping("/foosecret")
    public String fooSecret() {
        return "fooSecret: " + fooSecret;
    }
}
