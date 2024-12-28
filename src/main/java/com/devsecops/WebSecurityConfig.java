package com.devsecops;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@EnableWebSecurity
@Configuration
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            // Disable CSRF protection (only if not needed, e.g., REST APIs)
            .csrf().disable()

            // Add security headers via custom filter
            .addFilterAfter(new CustomHeaderFilter(), OncePerRequestFilter.class)

            // Configure URL-based authorization
            .authorizeRequests()
                // Permit access to actuator health/info endpoints
                .antMatchers("/actuator/health", "/actuator/info").permitAll()
                // Require authentication for other endpoints
                .anyRequest().authenticated()
            .and()

            // Add basic authentication (or replace with OAuth2/JWT for production)
            .httpBasic();
    }

    // Custom filter to add security headers
    public static class CustomHeaderFilter extends OncePerRequestFilter {
        @Override
        protected void doFilterInternal(
                HttpServletRequest request, 
                HttpServletResponse response, 
                FilterChain filterChain) throws ServletException, IOException {

            // Add headers for enhanced security
            response.addHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            response.addHeader("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-inline'; object-src 'none';");
            response.addHeader("X-Frame-Options", "DENY");
            response.addHeader("X-Content-Type-Options", "nosniff");
            response.addHeader("Cross-Origin-Resource-Policy", "same-origin");
            response.addHeader("Cross-Origin-Opener-Policy", "same-origin");
            
            // Proceed with the filter chain
            filterChain.doFilter(request, response);
        }
    }
}