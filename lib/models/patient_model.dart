class PatientModel {
  String nombre;
  int edad;
  String sexo;
  String actividad;
  double bpmPromedio;

  PatientModel({
    this.nombre = '',
    this.edad = 0,
    this.sexo = 'M',
    this.actividad = 'moderado',
    this.bpmPromedio = 0.0,
  });
}
