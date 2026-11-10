package com.misaludoasis.backend.modelos;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

@Entity
@Table(name = "recetas")
public class Receta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "paciente_id", nullable = false)
    // Aquí dejamos que el paciente se envíe, solo ignoramos los campos pesados
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "enfermedades", "alergias"})
    private Paciente paciente;

    @ManyToOne
    @JoinColumn(name = "medico_id")
    // Aquí dejamos que el médico se envíe
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Medico medico;

    @Column(name = "fecha_receta")
    private LocalDate fechaReceta;

    private String notas;
    private String diagnostico;
    private Integer edad;
    private String peso;
    private String altura;

    @Column(name = "fecha_creacion", insertable = false, updatable = false)
    private OffsetDateTime fechaCreacion;

    @OneToMany(mappedBy = "receta", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private List<RecetaDetalle> detalles;

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Paciente getPaciente() { return paciente; }
    public void setPaciente(Paciente paciente) { this.paciente = paciente; }
    public Medico getMedico() { return medico; }
    public void setMedico(Medico medico) { this.medico = medico; }
    public LocalDate getFechaReceta() { return fechaReceta; }
    public void setFechaReceta(LocalDate fechaReceta) { this.fechaReceta = fechaReceta; }
    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }
    public String getDiagnostico() { return diagnostico; }
    public void setDiagnostico(String diagnostico) { this.diagnostico = diagnostico; }
    public Integer getEdad() { return edad; }
    public void setEdad(Integer edad) { this.edad = edad; }
    public String getPeso() { return peso; }
    public void setPeso(String peso) { this.peso = peso; }
    public String getAltura() { return altura; }
    public void setAltura(String altura) { this.altura = altura; }
    public OffsetDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(OffsetDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public List<RecetaDetalle> getDetalles() { return detalles; }
    public void setDetalles(List<RecetaDetalle> detalles) { this.detalles = detalles; }
}