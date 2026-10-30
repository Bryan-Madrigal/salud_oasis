package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.modelos.Paciente;
import com.misaludoasis.backend.modelos.RegistroSeguimiento;
import com.misaludoasis.backend.repositorios.PacienteRepository;
import com.misaludoasis.backend.repositorios.RegistroSeguimientoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/seguimiento")
public class RegistroSeguimientoController {

    @Autowired
    private RegistroSeguimientoRepository registroRepository;

    @Autowired
    private PacienteRepository pacienteRepository;

    // Obtener historial de seguimiento de un paciente
    @GetMapping("/paciente/{pacienteId}")
    public List<RegistroSeguimiento> obtenerSeguimiento(@PathVariable Long pacienteId) {
        return registroRepository.findByPacienteIdOrderByFechaHoraDesc(pacienteId);
    }

    // Registrar una nueva toma (Glucosa o Presion)
    @PostMapping
    public ResponseEntity<?> crearRegistro(@RequestBody Map<String, Object> body) {
        try {
            Long pacienteId = Long.parseLong(body.get("pacienteId").toString());
            Optional<Paciente> pacOpt = pacienteRepository.findById(pacienteId);
            
            if (pacOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Paciente no encontrado"));
            }

            RegistroSeguimiento reg = new RegistroSeguimiento();
            reg.setPaciente(pacOpt.get());
            reg.setTipo((String) body.get("tipo"));
            reg.setNombreMostrar((String) body.get("nombreMostrar"));
            reg.setValor((String) body.get("valor"));
            reg.setUnidad((String) body.get("unidad"));
            reg.setObservaciones((String) body.get("observaciones"));
            reg.setMomento((String) body.get("momento"));
            reg.setFechaHora(OffsetDateTime.now());

            return ResponseEntity.ok(registroRepository.save(reg));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}