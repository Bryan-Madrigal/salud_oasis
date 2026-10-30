package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.dto.CitaRequest;
import com.misaludoasis.backend.modelos.Cita;
import com.misaludoasis.backend.modelos.Paciente;
import com.misaludoasis.backend.repositorios.CitaRepository;
import com.misaludoasis.backend.repositorios.MedicoRepository;
import com.misaludoasis.backend.repositorios.PacienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/citas")
public class CitaController {

    @Autowired
    private CitaRepository citaRepository;
    @Autowired
    private PacienteRepository pacienteRepository;
    @Autowired
    private MedicoRepository medicoRepository;

    @PostMapping
    public ResponseEntity<?> agendarCita(@RequestBody CitaRequest request) {
        Optional<Paciente> pacienteOpt = pacienteRepository.findById(request.getPacienteId());
        if (pacienteOpt.isEmpty()) return ResponseEntity.badRequest().body(Map.of("error", "Paciente no encontrado"));

        Cita cita = new Cita();
        cita.setPaciente(pacienteOpt.get());
        
        if (request.getMedicoId() != null) {
            medicoRepository.findById(request.getMedicoId()).ifPresent(cita::setMedico);
        }

        cita.setEspecialidad(request.getEspecialidad());
        cita.setTipo(request.getTipo());
        cita.setMotivo(request.getMotivo());
        cita.setFechaPreferida(request.getFechaPreferida());
        cita.setHorarioPreferido(request.getHorarioPreferido());
        cita.setNotasPaciente(request.getNotasPaciente());
        cita.setEstado("pendiente");

        return ResponseEntity.ok(citaRepository.save(cita));
    }

    // RUTA PARA EL MÉDICO
    @GetMapping("/medico/{medicoId}")
    public List<Cita> verTodasCitasMedico(@PathVariable Long medicoId) {
        return citaRepository.findAll().stream()
                .filter(c -> c.getMedico() != null && c.getMedico().getId().equals(medicoId))
                .toList();
    }

    // 👇 ESTA ERA LA RUTA QUE FALTABA PARA EL PACIENTE
    @GetMapping("/paciente/{pacienteId}")
    public List<Cita> verCitasPaciente(@PathVariable Long pacienteId) {
        return citaRepository.findAll().stream()
                .filter(c -> c.getPaciente() != null && c.getPaciente().getId().equals(pacienteId))
                .toList();
    }

    @PutMapping("/{id}/confirmar")
    public ResponseEntity<?> confirmarCita(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Optional<Cita> citaOpt = citaRepository.findById(id);
        if (citaOpt.isEmpty()) return ResponseEntity.notFound().build();

        Cita cita = citaOpt.get();
        cita.setEstado("confirmada");
        cita.setFechaHoraConfirmada(OffsetDateTime.parse(body.get("fechaHora").toString()));
        
        Object duracionObj = body.get("duracion");
        if (duracionObj != null) {
            cita.setDuracionMinutos(Integer.parseInt(duracionObj.toString()));
        }
        
        cita.setNotasMedico((String) body.get("notas"));

        return ResponseEntity.ok(citaRepository.save(cita));
    }
}