// HistorialTomaRepository.java
package com.misaludoasis.backend.repositorios;
import com.misaludoasis.backend.modelos.HistorialToma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HistorialTomaRepository extends JpaRepository<HistorialToma, Long> {
}