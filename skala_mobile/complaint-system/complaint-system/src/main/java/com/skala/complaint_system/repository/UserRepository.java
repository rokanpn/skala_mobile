package com.skala.complaint_system.repository;

import com.skala.complaint_system.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // ئەم دێڕە زیاد بکە ئەگەر نییە
    User findByEmail(String email);
}