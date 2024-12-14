package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.ui.Model;

@RestController
public class NumericController {

	private final Logger logger = LoggerFactory.getLogger(getClass());
	private static final String baseURL = "http://node-service:5000/plusone";
	
	RestTemplate restTemplate = new RestTemplate();
    

		@GetMapping("/compare/{value}")
		public String compareToFifty(@PathVariable int value) {
			String message = "Could not determine comparison";
			if (value > 50) {
				message = "Greater than 50";
			} else {
				message = "Smaller than or equal to 50";
			}
			return message;
		}

		@GetMapping("/increment/{value}")
public ModelAndView incrementThymeleaf(@PathVariable int value, Model model) {
    try {
        ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
        String response = responseEntity.getBody();
        logger.info("Value Received in Request - " + value);
        logger.info("Node Service Response - " + response);

        int incrementedValue = Integer.parseInt(response);

        // Add attributes to the model
        model.addAttribute("originalValue", value);
        model.addAttribute("incrementedValue", incrementedValue);

        return new ModelAndView("increment");
    } catch (Exception e) {
        logger.error("Error while contacting node service: ", e);
        return new ModelAndView("error");
    }
}


}

