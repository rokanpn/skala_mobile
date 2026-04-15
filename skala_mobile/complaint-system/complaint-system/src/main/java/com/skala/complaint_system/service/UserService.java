package com.skala.complaint_system.service;

import com.skala.complaint_system.model.User;
import com.skala.complaint_system.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder; // ئەمەمان گۆڕی بۆ ئەمە
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder; // ئێستا ئەمە بێ کێشە دەبێت

    public User registerUser(User user) {
        // شاردنەوەی پاسوورد پێش پاشکەوتکردن
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public User loginUser(String email, String password) {
        User user = userRepository.findByEmail(email);

        // لێرەدا PasswordEncoder بەراوردی پاسووردە شێوێندراوەکە و ئەوەی مۆبایلەکە دەکات
        if (user != null && passwordEncoder.matches(password, user.getPassword())) {
            return user;
        }
        return null;
    }
}