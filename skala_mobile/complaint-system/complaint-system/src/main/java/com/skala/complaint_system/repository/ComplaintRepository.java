package com.skala.complaint_system.repository;

import com.skala.complaint_system.model.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ComplaintRepository extends JpaRepository<Complaint, Long> {
    List<Complaint> findAllByOrderByCreatedAtDesc();
    List<Complaint> findByUserEmailOrderByCreatedAtDesc(String email);
}