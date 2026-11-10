package com.misaludoasis.backend.modelos;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
@Table(name = "recetas_detalle")
public class RecetaDetalle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "receta_id", nullable = false)
    @JsonIgnore
    private Receta receta;

    @Column(name = "nombre_medicamento")
    private String nombreMedicamento;

    private String dosis;
    private String frecuencia;
    private String duracion;
    
    @Column(name = "via_administracion")
    private String viaAdministracion; // NUEVO
    private String cantidad; // NUEVO

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Receta getReceta() { return receta; }
    public void setReceta(Receta receta) { this.receta = receta; }
    public String getNombreMedicamento() { return nombreMedicamento; }
    public void setNombreMedicamento(String nombreMedicamento) { this.nombreMedicamento = nombreMedicamento; }
    public String getDosis() { return dosis; }
    public void setDosis(String dosis) { this.dosis = dosis; }
    public String getFrecuencia() { return frecuencia; }
    public void setFrecuencia(String frecuencia) { this.frecuencia = frecuencia; }
    public String getDuracion() { return duracion; }
    public void setDuracion(String duracion) { this.duracion = duracion; }
    public String getViaAdministracion() { return viaAdministracion; } // NUEVO
    public void setViaAdministracion(String viaAdministracion) { this.viaAdministracion = viaAdministracion; } // NUEVO
    public String getCantidad() { return cantidad; } // NUEVO
    public void setCantidad(String cantidad) { this.cantidad = cantidad; } // NUEVO
}