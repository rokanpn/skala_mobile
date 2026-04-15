package com.skala.complaint_system.controller;

import com.skala.complaint_system.config.JwtUtil;
import com.skala.complaint_system.model.Notification;
import com.skala.complaint_system.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired private NotificationService notificationService;
    @Autowired private JwtUtil jwtUtil;

    private String getEmail(String header) {
        return jwtUtil.extractEmail(header.substring(7));
    }

    @GetMapping
    public ResponseEntity<List<Notification>> getMine(
            @RequestHeader("Authorization") String auth) {
        return ResponseEntity.ok(notificationService.getMyNotifications(getEmail(auth)));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Integer>> unreadCount(
            @RequestHeader("Authorization") String auth) {
        int count = notificationService.getUnreadCount(getEmail(auth));
        return ResponseEntity.ok(Map.of("count", count));
    }

    @PostMapping("/mark-read")
    public ResponseEntity<?> markRead(
            @RequestHeader("Authorization") String auth) {
        notificationService.markAllRead(getEmail(auth));
        return ResponseEntity.ok().build();
    }
}