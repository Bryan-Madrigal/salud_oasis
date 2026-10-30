package com.misaludoasis.backend.controladores;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class PruebaController {

    @GetMapping("/prueba")
    public String pruebaConexion() {
        return "¡El backend de Mi Salud Oasis esta funcionando y conectado a la base de datos!";
    }
}