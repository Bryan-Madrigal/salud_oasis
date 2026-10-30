package com.misaludoasis.backend.dto;

import java.time.LocalDate;

public class CitaRequest {
    private Long pacienteId;
    private Long medicoId; // Puede ser nulo si es una solicitud general
    private String especialidad;
    private String tipo;
    private String motivo;
    private LocalDate fechaPreferida;
    private String horarioPreferido;
    private String notasPaciente;

    // Getters y Setters
    public Long getPacienteId() { return pacienteId; }
    public void setPacienteId(Long pacienteId) { this.pacienteId = pacienteId; }
    public Long getMedicoId() { return medicoId; }
    public void setMedicoId(Long medicoId) { this.medicoId = medicoId; }
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
}