package com.skala.complaint_system.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "complaints")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String category;

    @Enumerated(EnumType.STRING)
    private Status status = Status.PENDING;

    private Double latitude;
    private Double longitude;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private User user;

    private int supportCount = 0;

    private LocalDateTime createdAt = LocalDateTime.now();

    public enum Status {
        PENDING, IN_PROGRESS, RESOLVED, REJECTED
    }
}