package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.modelos.Paciente;
import com.misaludoasis.backend.repositorios.PacienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map; // <-- IMPORTACIÓN QUE FALTABA

@RestController
@RequestMapping("/api/pacientes")
public class PacienteController {

    @Autowired
    private PacienteRepository pacienteRepository;

    // Obtener todos los pacientes
    @GetMapping
    public List<Paciente> listarPacientes() {
        return pacienteRepository.findAll();
    }

    // Obtener un paciente por su ID
    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerPaciente(@PathVariable Long id) {
        return pacienteRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Crear un paciente (por si lo necesitas)
    @PostMapping
    public Paciente crearPaciente(@RequestBody Paciente paciente) {
        return pacienteRepository.save(paciente);
    }

    // Actualizar datos clinicos de un paciente (Médico)
    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarPaciente(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        return pacienteRepository.findById(id).map(paciente -> {
            if (body.containsKey("edad")) paciente.setEdad(Integer.parseInt(body.get("edad").toString()));
            if (body.containsKey("sexo")) paciente.setSexo((String) body.get("sexo"));
            if (body.containsKey("tipoSangre")) paciente.setTipoSangre((String) body.get("tipoSangre"));
            
            if (body.containsKey("enfermedades")) {
                paciente.setEnfermedades((List<String>) body.get("enfermedades"));
            }
            if (body.containsKey("alergias")) {
                paciente.setAlergias((List<String>) body.get("alergias"));
            }
            
            pacienteRepository.save(paciente);
            return ResponseEntity.ok(paciente);
        }).orElse(ResponseEntity.notFound().build());
    }
}