package com.skala.complaint_system.service;

import com.skala.complaint_system.dto.ComplaintRequest;
import com.skala.complaint_system.model.Complaint;
import com.skala.complaint_system.model.User;
import com.skala.complaint_system.repository.ComplaintRepository;
import com.skala.complaint_system.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ComplaintService {

    @Autowired private ComplaintRepository complaintRepository;
    @Autowired private UserRepository userRepository;

    public Complaint createComplaint(ComplaintRequest req, String email) {
        User user = userRepository.findByEmail(email);
        Complaint c = new Complaint();
        c.setTitle(req.title);
        c.setDescription(req.description);
        c.setCategory(req.category);
        c.setLatitude(req.latitude);
        c.setLongitude(req.longitude);
        c.setUser(user);
        return complaintRepository.save(c);
    }

    public List<Complaint> getAll() {
        return complaintRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Complaint> getMine(String email) {
        return complaintRepository.findByUserEmailOrderByCreatedAtDesc(email);
    }

    public Complaint support(Long id) {
        Complaint c = complaintRepository.findById(id).orElseThrow();
        c.setSupportCount(c.getSupportCount() + 1);
        return complaintRepository.save(c);
    }
}