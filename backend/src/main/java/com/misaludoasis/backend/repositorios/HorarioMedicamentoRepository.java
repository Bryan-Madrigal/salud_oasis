package com.misaludoasis.backend.repositorios;

import com.misaludoasis.backend.modelos.HorarioMedicamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HorarioMedicamentoRepository extends JpaRepository<HorarioMedicamento, Long> {
}