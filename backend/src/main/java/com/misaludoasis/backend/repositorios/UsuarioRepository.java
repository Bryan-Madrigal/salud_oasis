package com.misaludoasis.backend.repositorios;

import com.misaludoasis.backend.modelos.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Esto nos servirá luego para el Login:
    Usuario findByCorreo(String correo);
}