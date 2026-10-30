package com.misaludoasis.backend.modelos;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Table(name = "citas")
public class Cita {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "paciente_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "enfermedades", "alergias"})
    private Paciente paciente;

    @ManyToOne
    @JoinColumn(name = "medico_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Medico medico;

    private String especialidad;
    private String tipo;
    
    @Column(nullable = false)
    private String motivo;
    
    @Column(name = "fecha_preferida", nullable = false)
    private LocalDate fechaPreferida;
    
    @Column(name = "horario_preferido", nullable = false)
    private String horarioPreferido;
    
    @Column(name = "notas_paciente")
    private String notasPaciente;

    @Column(name = "fecha_creacion", insertable = false, updatable = false)
    private OffsetDateTime fechaCreacion;

    @Column(name = "fecha_hora_confirmada")
    private OffsetDateTime fechaHoraConfirmada;

    @Column(name = "duracion_minutos")
    private Integer duracionMinutos = 30;

    @Column(name = "notas_medico")
    private String notasMedico;

    private String estado = "pendiente";

    // --- GETTERS Y SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Paciente getPaciente() { return paciente; }
    public void setPaciente(Paciente paciente) { this.paciente = paciente; }
    public Medico getMedico() { return medico; }
    public void setMedico(Medico medico) { this.medico = medico; }
    public String getEspecialidad() { return especialidad; }
    public void setEspecialidad(String especialidad) { this.especialidad = especialidad; }
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
    public LocalDate getFechaPreferida() { return fechaPreferida; }
    public void setFechaPreferida(LocalDate fechaPreferida) { this.fechaPreferida = fechaPreferida; }
    public String getHorarioPreferido() { return horarioPreferido; }
    public void setHorarioPreferido(String horarioPreferido) { this.horarioPreferido = horarioPreferido; }
    public String getNotasPaciente() { return notasPaciente; }
    public void setNotasPaciente(String notasPaciente) { this.notasPaciente = notasPaciente; }
    public OffsetDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(OffsetDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public OffsetDateTime getFechaHoraConfirmada() { return fechaHoraConfirmada; }
    public void setFechaHoraConfirmada(OffsetDateTime fechaHoraConfirmada) { this.fechaHoraConfirmada = fechaHoraConfirmada; }
    public Integer getDuracionMinutos() { return duracionMinutos; }
    public void setDuracionMinutos(Integer duracionMinutos) { this.duracionMinutos = duracionMinutos; }
    public String getNotasMedico() { return notasMedico; }
    public void setNotasMedico(String notasMedico) { this.notasMedico = notasMedico; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}