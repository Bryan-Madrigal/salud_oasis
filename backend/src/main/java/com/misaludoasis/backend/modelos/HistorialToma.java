package com.misaludoasis.backend.modelos;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Table(name = "historial_tomas")
public class HistorialToma {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "medicamento_id")
    @JsonIgnore 
    private Medicamento medicamento;

    @Column(name = "fecha_programada")
    private LocalDate fechaProgramada;

    @Column(name = "hora_programada")
    private String horaProgramada;

    private String estado; // "tomada", "omitida", "pendiente"

    @Column(name = "motivo_omision")
    private String motivoOmision;

    private String observaciones;

    @Column(name = "fecha_registro", insertable = false, updatable = false)
    private OffsetDateTime fechaRegistro;

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Medicamento getMedicamento() { return medicamento; }
    public void setMedicamento(Medicamento medicamento) { this.medicamento = medicamento; }
    public LocalDate getFechaProgramada() { return fechaProgramada; }
    public void setFechaProgramada(LocalDate fechaProgramada) { this.fechaProgramada = fechaProgramada; }
    public String getHoraProgramada() { return horaProgramada; }
    public void setHoraProgramada(String horaProgramada) { this.horaProgramada = horaProgramada; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getMotivoOmision() { return motivoOmision; }
    public void setMotivoOmision(String motivoOmision) { this.motivoOmision = motivoOmision; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
    public OffsetDateTime getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(OffsetDateTime fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}