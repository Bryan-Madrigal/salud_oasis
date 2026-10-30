package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.dto.LoginRequest;
import com.misaludoasis.backend.dto.RegistroRequest;
import com.misaludoasis.backend.modelos.Usuario;
import com.misaludoasis.backend.modelos.Paciente;
import com.misaludoasis.backend.modelos.Medico;
import com.misaludoasis.backend.repositorios.UsuarioRepository;
import com.misaludoasis.backend.repositorios.PacienteRepository;
import com.misaludoasis.backend.repositorios.MedicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private PacienteRepository pacienteRepository;
    @Autowired
    private MedicoRepository medicoRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findAll().stream()
                .filter(u -> u.getCorreo().equals(request.getCorreo()))
                .findFirst();

        if (usuarioOpt.isEmpty() || !usuarioOpt.get().getContrasenaHash().equals(request.getContrasena())) {
            return ResponseEntity.status(401).body(Map.of("error", "Correo o contraseña incorrectos"));
        }

        Usuario usuario = usuarioOpt.get();
        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Login exitoso");
        respuesta.put("nombre", usuario.getNombre());
        respuesta.put("rol", usuario.getRol());
        respuesta.put("correo", usuario.getCorreo());

        // Buscamos el ID del perfil específico (Paciente o Medico)
        if ("paciente".equals(usuario.getRol())) {
            Optional<Paciente> paciente = pacienteRepository.findByUsuarioId(usuario.getId());
            paciente.ifPresent(p -> respuesta.put("idPerfil", p.getId()));
        } else if ("medico".equals(usuario.getRol())) {
            Optional<Medico> medico = medicoRepository.findByUsuarioId(usuario.getId());
            medico.ifPresent(m -> respuesta.put("idPerfil", m.getId()));
        }

        return ResponseEntity.ok(respuesta);
    }

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody RegistroRequest request) {
        boolean existe = usuarioRepository.findAll().stream()
                .anyMatch(u -> u.getCorreo().equals(request.getCorreo()));
        
        if (existe) {
            return ResponseEntity.badRequest().body(Map.of("error", "El correo ya está registrado"));
        }

        String rolAsignado = request.getCorreo().toLowerCase().endsWith("@oasis.com") ? "medico" : "paciente";

        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombre(request.getNombre());
        nuevoUsuario.setCorreo(request.getCorreo());
        nuevoUsuario.setContrasenaHash(request.getContrasena());
        nuevoUsuario.setRol(rolAsignado);
        
        Usuario usuarioGuardado = usuarioRepository.save(nuevoUsuario);

        if ("paciente".equals(rolAsignado)) {
            Paciente nuevoPaciente = new Paciente();
            nuevoPaciente.setUsuario(usuarioGuardado);
            pacienteRepository.save(nuevoPaciente);
        } else if ("medico".equals(rolAsignado)) {
            Medico nuevoMedico = new Medico();
            nuevoMedico.setUsuario(usuarioGuardado);
            medicoRepository.save(nuevoMedico);
        }

        return ResponseEntity.ok(Map.of("mensaje", "Usuario registrado exitosamente"));
    }
}