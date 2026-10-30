package com.misaludoasis.backend.modelos;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
@Table(name = "horarios_medicamento")
public class HorarioMedicamento {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "medicamento_id")
    @JsonIgnore // Evita bucles infinitos en el JSON
    private Medicamento medicamento;

    @Column(name = "hora_dia")
    private String horaDia;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Medicamento getMedicamento() { return medicamento; }
    public void setMedicamento(Medicamento medicamento) { this.medicamento = medicamento; }
    public String getHoraDia() { return horaDia; }
    public void setHoraDia(String horaDia) { this.horaDia = horaDia; }
}