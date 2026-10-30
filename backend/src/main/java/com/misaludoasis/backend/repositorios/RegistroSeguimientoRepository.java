package com.misaludoasis.backend.repositorios;

import com.misaludoasis.backend.modelos.RegistroSeguimiento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RegistroSeguimientoRepository extends JpaRepository<RegistroSeguimiento, Long> {
    // Busca los registros de un paciente ordenados del mas reciente al mas antiguo
    List<RegistroSeguimiento> findByPacienteIdOrderByFechaHoraDesc(Long pacienteId);
}