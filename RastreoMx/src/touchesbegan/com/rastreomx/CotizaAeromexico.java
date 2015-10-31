package touchesbegan.com.rastreomx;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import touchesbegan.com.rastreomx.R;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;

public class CotizaAeromexico extends Activity {
	Spinner origen,destino;
	ArrayList<String>ciudades;
	HashMap <String,Integer> zonas;
	HashMap <String,Integer> precios;
	Button cotiza;
	TextView tv;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_cortiza_aeromexico);
		origen = (Spinner)findViewById(R.id.origen);
		destino = (Spinner)findViewById(R.id.destino);
		ciudades = new ArrayList<String>();
		zonas = new HashMap<String,Integer>();
		precios = new HashMap<String,Integer>();
		cotiza = (Button)findViewById(R.id.guardaEnvio);
		tv=(TextView)findViewById(R.id.precio);
		llenaSpinners();
		agregaCiudades();
		agregaPrecios();
		agregaZonas();
		cotiza.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				int total = cotiza(origen.getSelectedItem().toString(),destino.getSelectedItem().toString());
				tv.setText("precio desde: $ "+total);
			}
		});
		
	}
	 @SuppressWarnings({ "unchecked", "rawtypes" })
	public int cotiza(String origenS,String destinoS){
		Iterator it = zonas.entrySet().iterator();
		int zonaO =0;
		int zonaD =0;
		
		while(it.hasNext()){
		Map.Entry<String,Integer> e =(Map.Entry<String,Integer>)it.next();
		  if(e.getKey().equals(origenS)){
			  zonaO=e.getValue();
			  Log.v("ZOnaO",zonaO+"");
		  }
		  if(e.getKey().equals(destinoS)){
			  zonaD =e.getValue();
			  Log.v("ZOnaD",zonaD+"");
		  }
		}
		String x= buscaPrecio(zonaO,zonaD);
		Log.v("total",x);
		return buscaTotal(x);
	}
	 
	
	public int buscaTotal(String x ){
		int total =0;
		Iterator it = precios.entrySet().iterator();
		while(it.hasNext()){
			@SuppressWarnings("unchecked")
			Map.Entry<String,Integer> e =(Map.Entry<String,Integer>)it.next();
			if(e.getKey().equals(x)){
				total = e.getValue();
			}
		}
		return total;
	}
	 public String buscaPrecio(int d,int o){
		 String preciosM[][]={
				    {"A","B","B","B","C","D","C","E","F","G","F"},
		            {"A","B","B","B","B","D","C","F","G","G","G"},
		            {"C","A","A","A","A","B","C","E","F","G","F"},
		            {"D","C","A","A","A","B","C","D","F","G","F"},
		            {"D","C","B","A","A","A","C","D","E","F","F"},
		            {"D","C","B","A","A","B","C","C","D","E","D"},
		            {"E","E","C","B","C","B","A","D","E","G","F"},
		            {"F","E","E","C","C","C","C","A","C","B","C"},
		            {"G","F","F","E","E","D","D","C","B","C","B"},
		            {"G","G","G","E","C","C","D","B","C","A","C"},
		            {"F","F","E","E","E","D","F","F","C","D","A"}};
		String price="";
		price =preciosM[d][o];
		return price;
	}
	 
	public void llenaSpinners(){
		ciudades.add("Acapulco");
		ciudades.add("Aguascalientes");
		ciudades.add("Campeche");
		ciudades.add("Cancun");
		ciudades.add("Chetumal");
		ciudades.add("Chihuahua");
		ciudades.add("Ciudad del Carmen");
		ciudades.add("Ciudad Juarez");
		ciudades.add("Ciudad Obregon");
		ciudades.add("Cozumel");
		ciudades.add("Culiacan");
		ciudades.add("Durango");
		ciudades.add("Ensenada");
		ciudades.add("Guadalajara");
		ciudades.add("Hermosillo");
		ciudades.add("La Paz");
		ciudades.add("Los Mochis");
		ciudades.add("Matamoros");
		ciudades.add("Mazatlan");
		ciudades.add("Merida");
		ciudades.add("Mexicali");
		ciudades.add("Mexico");
		ciudades.add("Minatitlan");
		ciudades.add("Monterrey");
		ciudades.add("Nuevo Laredo");
		ciudades.add("Oaxaca");
		ciudades.add("Puebla");
		ciudades.add("Puerto Vallarta");
		ciudades.add("Queretaro");
		ciudades.add("Reynosa");
		ciudades.add("San Jose");
		ciudades.add("San Lucas");
		ciudades.add("San Luis Potosi");
		ciudades.add("Silao");
		ciudades.add("Tampico");
		ciudades.add("Tapachula");
		ciudades.add("Tijuana");
		ciudades.add("Toluca");
		ciudades.add("Torreon");
		ciudades.add("Tuxtla Gutierrez");
		ciudades.add("Veracruz");
		ciudades.add("Villahermosa");
		ciudades.add("Zihuatanejo");
	}
	
	public void agregaPrecios(){
		precios.put("A",200);
		precios.put("B",214);
		precios.put("C",216);
		precios.put("D",220);
		precios.put("E",254);
		precios.put("F",288);
		precios.put("G",300);
		
	}
	
	public void agregaZonas(){
		zonas.put("Acapulco",3);
		zonas.put("Aguascalientes",5);
		zonas.put("Campeche",0);
		zonas.put("Cancun",0);
		zonas.put("Chetumal",0);
		zonas.put("Chihuahua",8);
		zonas.put("Ciudad del Carmen",1);
		zonas.put("Ciudad Juarez",8);
		zonas.put("Ciudad Obregon",8);
		zonas.put("Cozumel",0);
		zonas.put("Culiacan",7);
		zonas.put("Durango",7);
		zonas.put("Ensenada",10);
		zonas.put("Guadalajara",5);
		zonas.put("Hermosillo",8);
		zonas.put("La Paz",9);
		zonas.put("Los Mochis",7);
		zonas.put("Matamoros",6);
		zonas.put("Mazatlan",7);
		zonas.put("Merida",0);
		zonas.put("Mexicali",10);
		zonas.put("Mexico",3);
		zonas.put("Minatitlan",2);
		zonas.put("Monterrey",6);
		zonas.put("Nuevo Laredo",6);
		zonas.put("Oaxaca",2);
		zonas.put("Puebla",3);
		zonas.put("Puerto Vallarta",5);
		zonas.put("Queretaro",3);
		zonas.put("Reynosa",6);
		zonas.put("San Jose",9);
		zonas.put("San Lucas",9);
		zonas.put("San Luis Potosi",4);
		zonas.put("Silao",4);
		zonas.put("Tampico",3);
		zonas.put("Tapachula",1);
		zonas.put("Tijuana",10);
		zonas.put("Toluca",3);
		zonas.put("Torreon",7);
		zonas.put("Tuxtla Gutierrez",1);
		zonas.put("Veracruz",2);
		zonas.put("Villahermosa",1);
		zonas.put("Zihuatanejo",3);

	}
	
	public void agregaCiudades(){
		ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this,
				android.R.layout.simple_spinner_item, ciudades);
		dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		origen.setAdapter(dataAdapter);
		destino.setAdapter(dataAdapter);
	}
}
