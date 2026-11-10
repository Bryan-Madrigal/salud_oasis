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
            receta.setDiagnostico((String) body.get("diagnostico")); // NUEVO
            
            if(body.get("edad") != null) receta.setEdad(Integer.parseInt(body.get("edad").toString()));
            if(body.get("peso") != null) receta.setPeso((String) body.get("peso"));
            if(body.get("altura") != null) receta.setAltura((String) body.get("altura"));

            List<Map<String, String>> detallesJson = (List<Map<String, String>>) body.get("detalles");
            List<RecetaDetalle> detalles = new ArrayList<>();

            if (detallesJson != null) {
                for (Map<String, String> d : detallesJson) {
                    RecetaDetalle detalle = new RecetaDetalle();
                    detalle.setReceta(receta);
                    detalle.setNombreMedicamento(d.get("nombreMedicamento"));
                    detalle.setDosis(d.get("dosis"));
                    detalle.setFrecuencia(d.get("frecuencia"));
                    detalle.setDuracion(d.get("duracion"));
                    detalle.setViaAdministracion(d.get("viaAdministracion")); // NUEVO
                    detalle.setCantidad(d.get("cantidad")); // NUEVO
                    detalles.add(detalle);
                }
            }
            receta.setDetalles(detalles);

            return ResponseEntity.ok(recetaRepository.save(receta));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}