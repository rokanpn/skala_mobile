package com.skala.complaint_system.service;

import com.skala.complaint_system.model.Notification;
import com.skala.complaint_system.model.User;
import com.skala.complaint_system.repository.NotificationRepository;
import com.skala.complaint_system.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class NotificationService {

    @Autowired private NotificationRepository notificationRepository;
    @Autowired private UserRepository userRepository;

    public void send(String email, String message, String type) {
        User user = userRepository.findByEmail(email);
        if (user == null) return;

        Notification n = new Notification();
        n.setUser(user);
        n.setMessage(message);
        n.setType(type);
        n.setRead(false); // دڵنیابەوە کە ئەم فیلدە لە ناو مۆدێلەکە هەیە
        notificationRepository.save(n);
    }

    public List<Notification> getMyNotifications(String email) {
        // ئێستا ئەم میتۆدە لە ڕیپۆزیتۆری ناسراوە
        return notificationRepository.findByUserEmailOrderByCreatedAtDesc(email);
    }

    public int getUnreadCount(String email) {
        return notificationRepository.countByUserEmailAndIsReadFalse(email);
    }

    public void markAllRead(String email) {
        List<Notification> list = notificationRepository.findByUserEmailOrderByCreatedAtDesc(email);
        list.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(list);
    }
}