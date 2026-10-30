package com.misaludoasis.backend.controladores;

import com.misaludoasis.backend.modelos.Medico;
import com.misaludoasis.backend.repositorios.MedicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/medicos")
public class MedicoController {

    @Autowired
    private MedicoRepository medicoRepository;

    @GetMapping
    public List<Medico> listarMedicos() {
        return medicoRepository.findAll();
    }
}