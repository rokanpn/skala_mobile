package com.skala.complaint_system.controller;

import com.skala.complaint_system.config.JwtUtil;
import com.skala.complaint_system.dto.ComplaintRequest;
import com.skala.complaint_system.model.Complaint;
import com.skala.complaint_system.service.ComplaintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/complaints")
@CrossOrigin(origins = "*")
public class ComplaintController {

    @Autowired private ComplaintService complaintService;
    @Autowired private JwtUtil jwtUtil;

    private String getEmail(String header) {
        return jwtUtil.extractEmail(header.substring(7));
    }

    @PostMapping
    public ResponseEntity<Complaint> create(
            @RequestHeader("Authorization") String auth,
            @RequestBody ComplaintRequest req) {
        return ResponseEntity.ok(complaintService.createComplaint(req, getEmail(auth)));
    }

    @GetMapping
    public ResponseEntity<List<Complaint>> getAll() {
        return ResponseEntity.ok(complaintService.getAll());
    }

    @GetMapping("/my")
    public ResponseEntity<List<Complaint>> getMine(
            @RequestHeader("Authorization") String auth) {
        return ResponseEntity.ok(complaintService.getMine(getEmail(auth)));
    }

    @PostMapping("/{id}/support")
    public ResponseEntity<Complaint> support(@PathVariable Long id) {
        return ResponseEntity.ok(complaintService.support(id));
    }
}