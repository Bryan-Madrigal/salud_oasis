package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.modelos.HistorialToma;
import com.misaludoasis.backend.modelos.HorarioMedicamento;
import com.misaludoasis.backend.modelos.Medicamento;
import com.misaludoasis.backend.modelos.Paciente;
import com.misaludoasis.backend.repositorios.HistorialTomaRepository;
import com.misaludoasis.backend.repositorios.HorarioMedicamentoRepository;
import com.misaludoasis.backend.repositorios.MedicamentoRepository;
import com.misaludoasis.backend.repositorios.PacienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/medicamentos")
public class MedicamentoController {

    @Autowired
    private MedicamentoRepository medicamentoRepository;
    
    @Autowired
    private HistorialTomaRepository historialTomaRepository;
    
    @Autowired
    private HorarioMedicamentoRepository horarioMedicamentoRepository;
    
    @Autowired
    private PacienteRepository pacienteRepository;

    // 1. Obtener todos los medicamentos de un paciente
    @GetMapping("/paciente/{pacienteId}")
    public List<Medicamento> verMedicamentosPaciente(@PathVariable Long pacienteId) {
        return medicamentoRepository.findByPacienteId(pacienteId);
    }

    // 2. Registrar que el paciente tomó el medicamento
    @PostMapping("/{medicamentoId}/tomar")
    public ResponseEntity<?> registrarToma(@PathVariable Long medicamentoId, @RequestBody Map<String, String> body) {
        Optional<Medicamento> medOpt = medicamentoRepository.findById(medicamentoId);
        if (medOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        HistorialToma toma = new HistorialToma();
        toma.setMedicamento(medOpt.get());
        toma.setFechaProgramada(LocalDate.parse(body.get("fecha")));
        toma.setHoraProgramada(body.get("hora"));
        toma.setEstado("tomada");

        return ResponseEntity.ok(historialTomaRepository.save(toma));
    }

    // 3. Médico receta un nuevo medicamento
    @PostMapping
    public ResponseEntity<?> recetarMedicamento(@RequestBody Map<String, Object> body) {
        try {
            Long pacienteId = Long.parseLong(body.get("pacienteId").toString());
            Optional<Paciente> pacienteOpt = pacienteRepository.findById(pacienteId);
            
            if (pacienteOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Paciente no encontrado"));
            }

            Medicamento med = new Medicamento();
            med.setPaciente(pacienteOpt.get());
            med.setNombre((String) body.get("nombre"));
            med.setDosis((String) body.get("dosis"));
            med.setFrecuencia((String) body.get("frecuencia"));
            med.setFechaInicio(LocalDate.parse(body.get("fechaInicio").toString()));
            med.setFechaFin(LocalDate.parse(body.get("fechaFin").toString()));
            med.setNotas((String) body.get("notas"));
            med.setEstado("activo");

            // Guardamos el medicamento primero para que genere su ID
            Medicamento medGuardado = medicamentoRepository.save(med);

            // Si el médico puso una hora, creamos el horario
            if (body.get("horaRecordatorio") != null) {
                HorarioMedicamento horario = new HorarioMedicamento();
                horario.setMedicamento(medGuardado);
                horario.setHoraDia((String) body.get("horaRecordatorio"));
                horarioMedicamentoRepository.save(horario);
            }

            return ResponseEntity.ok(medGuardado);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}