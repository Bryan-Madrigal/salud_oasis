package com.misaludoasis.backend.repositorios;

import com.misaludoasis.backend.modelos.Cita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {
    // Para buscar las citas de un médico específico (ej. estado "pendiente")
    List<Cita> findByMedicoIdAndEstado(Long medicoId, String estado);
    
    // Para buscar el historial de citas de un paciente
    List<Cita> findByPacienteId(Long pacienteId);
}