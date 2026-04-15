package com.skala.complaint_system.controller;

import com.skala.complaint_system.config.JwtUtil;
import com.skala.complaint_system.dto.LoginResponse;
import com.skala.complaint_system.model.User;
import com.skala.complaint_system.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        try {
            User saved = userService.registerUser(user);
            String token = jwtUtil.generateToken(saved.getEmail(), saved.getRole().name());
            return ResponseEntity.ok(new LoginResponse(token, saved.getName(), saved.getEmail(), saved.getRole().name()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("ئەم ئیمەیڵە پێشتر تۆمار کراوە");
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        User found = userService.loginUser(user.getEmail(), user.getPassword());
        if (found != null) {
            String token = jwtUtil.generateToken(found.getEmail(), found.getRole().name());
            return ResponseEntity.ok(new LoginResponse(token, found.getName(), found.getEmail(), found.getRole().name()));
        }
        return ResponseEntity.status(401).body("ئیمەیڵ یان پاسووردی هەڵەیە");
    }
}