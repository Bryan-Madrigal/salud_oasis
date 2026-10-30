package com.misaludoasis.backend.config;

import com.misaludoasis.backend.modelos.Medico;
import com.misaludoasis.backend.modelos.Usuario;
import com.misaludoasis.backend.repositorios.MedicoRepository;
import com.misaludoasis.backend.repositorios.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.Optional;

@Component
public class DataSeeder implements CommandLineRunner {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private MedicoRepository medicoRepository;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("Verificando datos iniciales de medicos...");

        // MEDICINA GENERAL
        crearMedico("Joel Encinos", "joel@oasis.com", "Medicina general", "Consultorio 1");
        crearMedico("Ana Garcia", "ana@oasis.com", "Medicina general", "Consultorio 2");
        crearMedico("Carlos Lopez", "carlos@oasis.com", "Medicina general", "Consultorio 3");

        // CARDIOLOGIA
        crearMedico("Maria Martinez", "maria@oasis.com", "Cardiologia", "Consultorio 4");
        crearMedico("Jorge Rodriguez", "jorge@oasis.com", "Cardiologia", "Consultorio 5");
        crearMedico("Luisa Fernandez", "luisa@oasis.com", "Cardiologia", "Consultorio 6");

        // ENDOCRINOLOGIA
        crearMedico("Pedro Sanchez", "pedro@oasis.com", "Endocrinologia", "Consultorio 7");
        crearMedico("Laura Gomez", "laura@oasis.com", "Endocrinologia", "Consultorio 8");
        crearMedico("Ricardo Diaz", "ricardo@oasis.com", "Endocrinologia", "Consultorio 9");

        // NEFROLOGIA
        crearMedico("Elena Torres", "elena@oasis.com", "Nefrologia", "Consultorio 10");
        crearMedico("Miguel Ruiz", "miguel@oasis.com", "Nefrologia", "Consultorio 11");
        crearMedico("Sofia Ramirez", "sofia@oasis.com", "Nefrologia", "Consultorio 12");

        // NEUMOLOGIA
        crearMedico("David Flores", "david@oasis.com", "Neumologia", "Consultorio 13");
        crearMedico("Carmen Castro", "carmen@oasis.com", "Neumologia", "Consultorio 14");
        crearMedico("Javier Ortega", "javier@oasis.com", "Neumologia", "Consultorio 15");
        
        System.out.println("Verificacion de medicos completada.");
    }

    private void crearMedico(String nombre, String correo, String especialidad, String consultorio) {
        Optional<Usuario> usuarioExistente = usuarioRepository.findAll().stream()
                .filter(u -> u.getCorreo().equals(correo))
                .findFirst();

        Usuario usuario;

        if (usuarioExistente.isEmpty()) {
            // Si el usuario no existe, lo creamos
            Usuario nuevoUsuario = new Usuario();
            nuevoUsuario.setNombre(nombre);
            nuevoUsuario.setCorreo(correo);
            nuevoUsuario.setContrasenaHash("123");
            nuevoUsuario.setRol("medico");
            usuario = usuarioRepository.save(nuevoUsuario);
        } else {
            usuario = usuarioExistente.get();
        }

        // Ahora verificamos si tiene perfil de medico
        Optional<Medico> perfilMedico = medicoRepository.findByUsuarioId(usuario.getId());

        if (perfilMedico.isEmpty()) {
            // Si no tiene perfil, se lo creamos (esto es lo que le paso a Joel)
            Medico medico = new Medico();
            medico.setUsuario(usuario);
            medico.setEspecialidad(especialidad);
            medico.setConsultorio(consultorio);
            medico.setCalificacion(new BigDecimal("4.8"));
            medicoRepository.save(medico);
        } else {
            // Si ya tiene perfil pero no tiene especialidad (como Joel), se la asignamos
            Medico medico = perfilMedico.get();
            if (medico.getEspecialidad() == null || medico.getEspecialidad().isEmpty()) {
                medico.setEspecialidad(especialidad);
                medico.setConsultorio(consultorio);
                medico.setCalificacion(new BigDecimal("4.8"));
                medicoRepository.save(medico);
            }
        }
    }
}