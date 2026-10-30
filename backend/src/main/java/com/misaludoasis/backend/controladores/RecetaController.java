package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.modelos.*;
import com.misaludoasis.backend.repositorios.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recetas")
public class RecetaController {

    @Autowired
    private RecetaRepository recetaRepository;
    @Autowired
    private PacienteRepository pacienteRepository;
    @Autowired
    private MedicoRepository medicoRepository;
    
    // NUEVOS REPOSITORIOS
    @Autowired
    private MedicamentoRepository medicamentoRepository;
    @Autowired
    private HorarioMedicamentoRepository horarioRepository;

    @GetMapping("/paciente/{pacienteId}")
    public List<Receta> verRecetasPaciente(@PathVariable Long pacienteId) {
        return recetaRepository.findByPacienteIdOrderByFechaRecetaDesc(pacienteId);
    }

    @GetMapping("/medico/{medicoId}")
    public List<Receta> verRecetasMedico(@PathVariable Long medicoId) {
        return recetaRepository.findByMedicoIdOrderByFechaRecetaDesc(medicoId);
    }

    @PostMapping
    public ResponseEntity<?> crearReceta(@RequestBody Map<String, Object> body) {
        try {
            Long pacienteId = Long.parseLong(body.get("pacienteId").toString());
            Long medicoId = Long.parseLong(body.get("medicoId").toString());

            Paciente paciente = pacienteRepository.findById(pacienteId).orElse(null);
            Medico medico = medicoRepository.findById(medicoId).orElse(null);

            if (paciente == null || medico == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Paciente o Medico no encontrado"));
            }

            Receta receta = new Receta();
            receta.setPaciente(paciente);
            receta.setMedico(medico);
            receta.setFechaReceta(LocalDate.now());
            receta.setNotas((String) body.get("notas"));

            List<Map<String, String>> detallesJson = (List<Map<String, String>>) body.get("detalles");
            List<RecetaDetalle> detalles = new ArrayList<>();

            if (detallesJson != null) {
                for (Map<String, String> d : detallesJson) {
                    // 1. Guardar el detalle de la receta (Para el documento)
                    RecetaDetalle detalle = new RecetaDetalle();
                    detalle.setReceta(receta);
                    detalle.setNombreMedicamento(d.get("nombreMedicamento"));
                    detalle.setDosis(d.get("dosis"));
                    detalle.setFrecuencia(d.get("frecuencia"));
                    detalle.setDuracion(d.get("duracion"));
                    detalles.add(detalle);

                    // 2. MAGIA: Crear el medicamento para los recordatorios del paciente
                    Medicamento med = new Medicamento();
                    med.setPaciente(paciente);
                    med.setNombre(d.get("nombreMedicamento"));
                    med.setDosis(d.get("dosis"));
                    med.setFrecuencia(d.get("frecuencia"));
                    med.setFechaInicio(LocalDate.now());
                    med.setFechaFin(LocalDate.now().plusMonths(1)); // Le damos 1 mes por defecto
                    med.setEstado("activo");
                    
                    Medicamento medGuardado = medicamentoRepository.save(med);

                    // 3. Crear un horario por defecto (08:00 AM)
                    HorarioMedicamento horario = new HorarioMedicamento();
                    horario.setMedicamento(medGuardado);
                    horario.setHoraDia("08:00"); // Hora por defecto
                    horarioRepository.save(horario);
                }
            }
            receta.setDetalles(detalles);

            return ResponseEntity.ok(recetaRepository.save(receta));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}