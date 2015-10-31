package touchesbegan.com.rastreomx;

import java.util.ArrayList;

import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import touchesbegan.com.rastreomx.R;
import touchesbegan.com.rastreomx.R.drawable;
import touchesbegan.rastreomx.database.MySQLiteHelper;
import touchesbegan.rastreomx.database.Paquete;
import android.app.ActionBar;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class Infodepaquete extends Activity {
	Button btn;
	ListView listView;
	Button guardar;
	ArrayAdapter<String> adapter;

	TextView numGuia, origen, destino, fecha, situacion, recibio, guia, t2, t3,
			t4, t5, t6;
	String paqueteria;
	ImageView iv;

	private MySQLiteHelper db;
	String OutputData = "";
	String id;
	String paq = "";
	JSONObject jsonChildNode2;
	ArrayList<String> a;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_infodepaquete);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		btn = (Button)findViewById(R.id.guardaEnvio);
		btn.setBackgroundColor(Color.argb(127, 255, 0, 0));
		btn.setTextColor(Color.WHITE);
		iv = (ImageView) findViewById(R.id.imageViewtracking);
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));
		db = new MySQLiteHelper(getApplicationContext());
		numGuia = (TextView) findViewById(R.id.tracking);
		origen = (TextView) findViewById(R.id.textOrigen);
		destino = (TextView) findViewById(R.id.textDestino);
		fecha = (TextView) findViewById(R.id.textFecha);
		situacion = (TextView) findViewById(R.id.textSituacion);
		recibio = (TextView) findViewById(R.id.textQuien);

		guia = (TextView) findViewById(R.id.guia);
		t2 = (TextView) findViewById(R.id.textView1);
		t3 = (TextView) findViewById(R.id.textView2);
		t4 = (TextView) findViewById(R.id.precio);
		t5 = (TextView) findViewById(R.id.textView4);
		t6 = (TextView) findViewById(R.id.textView5);

		id = getIntent().getStringExtra("id");

		a = getIntent().getStringArrayListExtra("resultado");

		ensureSize(a, 6);

		if (a.get(0) == null || a.get(0).equals("")) {
			numGuia.setVisibility(View.GONE);
			guia.setVisibility(View.GONE);
		} else {
			numGuia.setText(a.get(0));
		}

		if (a.get(1) == null || a.get(1).equals("")) {
			origen.setVisibility(View.GONE);
			t2.setVisibility(View.GONE);
		} else {
			origen.setText(a.get(1));
		}

		if (a.get(2) == null || a.get(2).equals("")) {
			destino.setVisibility(View.GONE);
			t3.setVisibility(View.GONE);
		} else {
			destino.setText(a.get(2));
		}
		if (a.get(3) == null || a.get(3).equals("")) {
			fecha.setVisibility(View.GONE);
			t4.setVisibility(View.GONE);
		} else {
			fecha.setText(a.get(3));
		}
		if (a.get(4) == null || a.get(4).equals("")) {
			situacion.setVisibility(View.GONE);
			t5.setVisibility(View.GONE);
		} else {
			situacion.setText(a.get(4));
		}
		if (a.get(5) == null || a.get(5).equals("")) {
			recibio.setVisibility(View.GONE);
			t6.setVisibility(View.GONE);
		} else {
			recibio.setText(a.get(5));
		}

		switch (Integer.parseInt(id)) {
		case 1:
			iv.setImageResource(drawable.multipack);
			paqueteria="Multipack";
			break;
		case 2:
			iv.setImageResource(drawable.ups);
			paqueteria="UPS";
			break;
		case 3:
			iv.setImageResource(drawable.dhl);
			paqueteria="DHL";
			break;
		case 4:
			iv.setImageResource(drawable.fedex);
			paqueteria="Fedex";
			break;
		case 5:
			iv.setImageResource(drawable.correosdemexico);
			paqueteria="Correos de Mexico";
			break;
		case 6:
			iv.setImageResource(drawable.estafeta);
			paqueteria="Estafeta";
			break;
		case 7:
			iv.setImageResource(drawable.paquete_express);
			paqueteria="Paquete express";
			break;
		case 8:
			iv.setImageResource(drawable.paquer);
			paqueteria="Paquer";
			break;
		case 9:
			iv.setImageResource(drawable.redpack);
			paqueteria="Redpack";
			break;
		case 10:
			iv.setImageResource(drawable.envia);
			paqueteria="Envia";
			break;
		case 11:
			iv.setImageResource(drawable.aeromexico);
			paqueteria="Aeromexico Cargo";
			break;
		case 12:
			iv.setImageResource(drawable.tresguerras);
			paqueteria="Tres guerras";
			break;
		case 13:
			iv.setImageResource(drawable.castores);
			paqueteria="Castores";
			break;
		case 14:
			iv.setImageResource(drawable.odmexpress);
			paqueteria="ODM express";
			break;
		case 15:
			iv.setImageResource(drawable.flechaamarilla);
			paqueteria="Flecha amarilla";
			break;
		

		}

	}

	public void InsertaDatos(View v) {

		new SaveIntoDB().execute();
	}

	public void Volver(View v) {
		Intent volver = new Intent(this, MainActivity.class);
		startActivity(volver);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.infodepaquete, menu);
		return true;
	}

	public static void ensureSize(ArrayList<?> list, int size) {
		// Prevent excessive copying while we're adding
		list.ensureCapacity(size);
		while (list.size() < size) {
			list.add(null);
		}
	}

	private class SaveIntoDB extends AsyncTask<Void, Void, Void> {
		ProgressDialog mProgressDialog;
		
		protected void onPreExecute() {
			super.onPreExecute();
			mProgressDialog = new ProgressDialog(Infodepaquete.this);
			mProgressDialog.setTitle("Guardado de envíos");
			mProgressDialog.setMessage("Guardando envío...");
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.show();
		}

		@Override
		protected Void doInBackground(Void... arg0) {

			try {
				String clave = numGuia.getText().toString();
				String origenS = origen.getText().toString();
				String destinoS = destino.getText().toString();
				String fechaS = fecha.getText().toString();
				String situacionS = situacion.getText().toString();
				String recibioS = recibio.getText().toString();
				db.insertaPaquete(clave,paqueteria ,origenS, destinoS, fechaS, situacionS, recibioS);
			} catch (Exception e) {

				e.printStackTrace();
			}
			return null;
		}

		protected void onPostExecute(Void result) {
			Intent i = new Intent(Infodepaquete.this, Misenvios.class);
			startActivity(i);
			mProgressDialog.dismiss();
		}
	}

}
