// RecetaRepository.java
package com.misaludoasis.backend.repositorios;

import com.misaludoasis.backend.modelos.Receta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RecetaRepository extends JpaRepository<Receta, Long> {
    List<Receta> findByPacienteIdOrderByFechaRecetaDesc(Long pacienteId);
    List<Receta> findByMedicoIdOrderByFechaRecetaDesc(Long medicoId);
}