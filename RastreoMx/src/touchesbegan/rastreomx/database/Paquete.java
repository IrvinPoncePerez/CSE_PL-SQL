package touchesbegan.rastreomx.database;

import java.io.Serializable;

public class Paquete implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private int id;
	private String clave;
	private String paqueteria;
	private String origen;
	private String destino;
	private String fecha;
	private String situacion;
	private String quien;
	
	public Paquete(int id,String clave, String origen, String destino, String fecha,
			String situacion, String quien) {
		super();
		this.id = id;
		this.clave = clave;
		this.origen = origen;
		this.destino = destino;
		this.fecha = fecha;
		this.situacion = situacion;
		this.quien = quien;
	}
	public Paquete(int id,String clave){
		this.id = id;
		this.clave = clave;
	}
	public Paquete(){
		
	}
	
	
	
	public String getPaqueteria() {
		return paqueteria;
	}
	public void setPaqueteria(String paqueteria) {
		this.paqueteria = paqueteria;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getClave() {
		return clave;
	}
	public void setClave(String clave) {
		this.clave = clave;
	}
	public String getOrigen() {
		return origen;
	}
	public void setOrigen(String origen) {
		this.origen = origen;
	}
	public String getDestino() {
		return destino;
	}
	public void setDestino(String destino) {
		this.destino = destino;
	}
	public String getFecha() {
		return fecha;
	}
	public void setFecha(String fecha) {
		this.fecha = fecha;
	}
	public String getSituacion() {
		return situacion;
	}
	public void setSituacion(String situacion) {
		this.situacion = situacion;
	}
	public String getQuien() {
		return quien;
	}
	public void setQuien(String quien) {
		this.quien = quien;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	@Override
	public String toString() {
		return "No. guia:\n "+clave+"\n"+
				"paqueteria:\n "+paqueteria+"\n ";
	}
	
	
	

}
