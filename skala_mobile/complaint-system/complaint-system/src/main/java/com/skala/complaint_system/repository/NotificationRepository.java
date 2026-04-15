package com.skala.complaint_system.repository;

import com.skala.complaint_system.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // دۆزینەوەی نۆتیفیکەیشنەکان بەپێی ئیمەیڵی بەکارهێنەر
    List<Notification> findByUserEmailOrderByCreatedAtDesc(String email);

    // ژمارەی ئەو نۆتیفیکەیشنانەی کە هێشتا نەخوێندراونەتەوە
    int countByUserEmailAndIsReadFalse(String email);
}