package touchesbegan.com.rastreomx;

import touchesbegan.rastreomx.cotizadores.CotizadorDHL;
import touchesbegan.rastreomx.cotizadores.CotizadorESTAFETA;
import touchesbegan.rastreomx.cotizadores.CotizadorFEDEX;
import touchesbegan.rastreomx.cotizadores.CotizadorUPS;
import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

public class Cotizar extends Activity {
	EditText origen;
	EditText destino;
	TextView cantidad;
	double dinero;
	String sel = "a";
	String compania;
	String ori;
	String des;
	ScrollView s;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_cotizar);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));
		origen = (EditText) findViewById(R.id.editTextvalueOrigen);
		destino = (EditText) findViewById(R.id.editTextvalueDestino);
		cantidad = (TextView) findViewById(R.id.cantidad);
		s = (ScrollView) findViewById(R.id.scrollView1);
		new AlertDialog.Builder(this)
				.setTitle("Cotizador")
				.setMessage(
						"El monto esta basado en un paquete de 1Kg. Para tener más información consulte a su proveedor.")
				.setNeutralButton(android.R.string.ok,
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int which) {
								// continue with delete
							}
						}).setIcon(android.R.drawable.ic_dialog_alert).show();

	}

	public void proveedor(View v) {
		switch (v.getId()) {
		case R.id.ups:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.ups);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.dhl:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.dhl);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.fedex:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.fedex);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.correos:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;
			} else {
				new AlertDialog.Builder(this)
						.setTitle("Correos de México")
						.setMessage(
								"El monto es de $28 y está basado en un paquete de 1Kg. Para tener más información consulte Correos de México.")
						.setNeutralButton(android.R.string.ok,
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog,
											int which) {
										// continue with delete
									}
								}).setIcon(android.R.drawable.ic_dialog_alert)
						.show();
			}
			break;
		case R.id.estafeta:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.estafeta);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;

		case R.id.envia:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.envia);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.paquete_express:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.paquete_express);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.paquer:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.paquer);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.tresGuerras:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				new AlertDialog.Builder(this)
				.setTitle("Correos de México")
				.setMessage(
						"El monto es desde $150 y está basado en un paquete menor a 100Kg. Para tener más información consulte Tres Guerras.")
				.setNeutralButton(android.R.string.ok,
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int which) {
								// continue with delete
							}
						}).setIcon(android.R.drawable.ic_dialog_alert)
				.show();
			}
			break;
		case R.id.enviar:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.enviar);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.fAmarilla:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.fAmarilla);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.button3:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.button3);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.odm:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.odm);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		case R.id.redpack:
			if (origen.length() == 0 || destino.length() == 0) {
				Toast.makeText(
						getApplicationContext(),
						"alguno de los campos están vacíos, por favor llénalos",
						Toast.LENGTH_LONG).show();
				break;

			} else {
				double precio = cotizar(firstLetter(origen.getText().charAt(0)
						+ ""), firstLetter(destino.getText().charAt(0) + ""),
						R.id.redpack);
				cantidad.setText("Monto desde: $" + precio);
			}
			break;
		}

	}

	public double cotizar(int origen, int destino, int paqueteria) {
		if ((origen == 0 && destino == 0) || (origen == 0 && destino == 1)
				|| (origen == 1 && destino == 0)
				|| (origen == 0 && destino == 6)
				|| (origen == 6 && destino == 0)
				|| (origen == 5 && destino == 1)
				|| (origen == 1 && destino == 6)
				|| (origen == 0 && destino == 4)
				|| (origen == 1 && destino == 4)
				|| (origen == 4 && destino == 1)
				|| (origen == 4 && destino == 0)
				|| (origen == 3 && destino == 3)
				|| (origen == 4 && destino == 6)
				|| (origen == 6 && destino == 4)
				|| (origen == 4 && destino == 0)
				|| (origen == 5 && destino == 0)
				|| (origen == 6 && destino == 0)
				|| (origen == 7 && destino == 0)
				|| (origen == 8 && destino == 0)
				|| (origen == 9 && destino == 0)
				|| (origen == 0 && destino == 5)
				|| (origen == 0 && destino == 6)
				|| (origen == 0 && destino == 7)
				|| (origen == 5 && destino == 5)
				|| (origen == 6 && destino == 1)
				|| (origen == 7 && destino == 7)
				|| (origen == 7 && destino == 1)
				|| (origen == 1 && destino == 7)
				|| (origen == 0 && destino == 9)) {
			switch (paqueteria) {
			case R.id.ups:
				return 238.50;
			case R.id.dhl:
				return 157.10;
			case R.id.fedex:
				return 257.50;
			case R.id.estafeta:
				return 331.32;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 167.40;
			case R.id.enviar://aeromexico
				return 180.30;
			case R.id.fAmarilla:
				return 168.30;
			case R.id.button3://castores
				return 170.30;
			case R.id.odm:
				return 145.30;
			}

		}
		if ((origen == 0 && destino == 2) 
				|| (origen == 2 && destino == 0)
				|| (origen == 7 && destino == 3)
				|| (origen == 7 && destino == 5)
				|| (origen == 8 && destino == 2)
				|| (origen == 4 && destino == 4)) {
			switch (paqueteria) {
			case R.id.ups:
				return 278.50;
			case R.id.dhl:
				return 227.00;
			case R.id.fedex:
				return 359.00;
			case R.id.estafeta:
				return 465.60;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 227.00;
			case R.id.tresGuerras:
				return 160.30;
			case R.id.enviar:
				return 160.30;
			case R.id.fAmarilla:
				return 168.30;
			case R.id.button3:
				return 169.30;
			case R.id.odm:
				return 159.30;

			}

		}
		if ((origen == 6 && destino == 3) || (origen == 0 && destino == 3)
				|| (origen == 2 && destino == 3)
				|| (origen == 4 && destino == 3)
				|| (origen == 3 && destino == 6)
				|| (origen == 3 && destino == 2)
				|| (origen == 3 && destino == 4)
				|| (origen == 3 && destino == 8)
				|| (origen == 8 && destino == 3)
				|| (origen == 8 && destino == 1)
				|| (origen == 5 && destino == 3)
				|| (origen == 2 && destino == 2)) {
			switch (paqueteria) {
			case R.id.ups:
				return 316.60;
			case R.id.dhl:
				return 231;
			case R.id.fedex:
				return 404.50;
			case R.id.estafeta:
				return 516.20;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 231;
			case R.id.tresGuerras:
				return 150.30;
			case R.id.enviar:
				return 240.30;
			case R.id.fAmarilla:
				return 231;
			case R.id.button3:
				return 240;
			case R.id.odm:
				return 200;

			}

		}
		if ((origen == 2 && destino == 1) || (origen == 1 && destino == 2)
				|| (origen == 3 && destino == 1)
				|| (origen == 1 && destino == 3)
				|| (origen == 4 && destino == 2)
				|| (origen == 4 && destino == 3)
				|| (origen == 3 && destino == 4)
				|| (origen == 3 && destino == 5)
				|| (origen == 3 && destino == 7)
				|| (origen == 3 && destino == 9)
				|| (origen == 2 && destino == 4)) {
			switch (paqueteria) {
			case R.id.ups:
				return 255.60;
			case R.id.dhl:
				return 194.50;
			case R.id.fedex:
				return 312.50;
			case R.id.estafeta:
				return 415.11;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 194.50;
			case R.id.tresGuerras:
				return 180.30;
			case R.id.enviar:
				return 180;
			case R.id.fAmarilla:
				return 170;
			case R.id.button3:
				return 185;
			case R.id.odm:
				return 140;

			}

		}
		if ((origen == 6 && destino == 3) || (origen == 6 && destino == 2)
				|| (origen == 3 && destino == 6)
				|| (origen == 2 && destino == 6)
				|| (origen == 8 && destino == 2)
				|| (origen == 2 && destino == 8)
				|| (origen == 6 && destino == 4)
				|| (origen == 6 && destino == 5)
				|| (origen == 6 && destino == 7)
				|| (origen == 4 && destino == 6)
				|| (origen == 5 && destino == 6)
				|| (origen == 7 && destino == 6)
				|| (origen == 7 && destino == 4)
				|| (origen == 5 && destino == 4)
				|| (origen == 4 && destino == 7)
				|| (origen == 4 && destino == 5)
				|| (origen == 9 && destino == 4)
				|| (origen == 9 && destino == 0)
				|| (origen == 0 && destino == 9)
				|| (origen == 4 && destino == 9)) {
			switch (paqueteria) {
			case R.id.ups:
				return 235.50;
			case R.id.dhl:
				return 75.50;
			case R.id.fedex:
				return 238.00;
			case R.id.estafeta:
				return 303.43;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 157.10;
			case R.id.tresGuerras:
				return 180;
			case R.id.enviar:
				return 160;
			case R.id.fAmarilla:
				return 170;
			case R.id.button3:
				return 175;
			case R.id.odm:
				return 178.50;

			}

		}
		if ((origen == 0 && destino == 4) || (origen == 4 && destino == 0)
				|| (origen == 1 && destino == 4)
				|| (origen == 4 && destino == 1)
				|| (origen == 3 && destino == 1)
				|| (origen == 1 && destino == 3)) {
			switch (paqueteria) {
			case R.id.ups:
				return 235.50;
			case R.id.dhl:
				return 175.50;
			case R.id.fedex:
				return 266.00;
			case R.id.estafeta:
				return 387.11;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 175.00;
			case R.id.tresGuerras:
				return 180.30;
			case R.id.enviar:
				return 185;
			case R.id.fAmarilla:
				return 165;
			case R.id.button3:
				return 173.50;
			case R.id.odm:
				return 150.30;

			}

		}
		if ((origen == 3 && destino == 8) || (origen == 4 && destino == 8)
				|| (origen == 8 && destino == 3)
				|| (origen == 8 && destino == 4)
				|| (origen == 5 && destino == 2)
				|| (origen == 6 && destino == 2)
				|| (origen == 7 && destino == 2)
				|| (origen == 2 && destino == 5)
				|| (origen == 2 && destino == 6)
				|| (origen == 2 && destino == 7)
				|| (origen == 4 && destino == 8)
				|| (origen == 5 && destino == 8)
				|| (origen == 6 && destino == 8)
				|| (origen == 6 && destino == 9)
				|| (origen == 7 && destino == 9)
				|| (origen == 7 && destino == 8)) {
			switch (paqueteria) {
			case R.id.ups:
				return 331.30;
			case R.id.dhl:
				return 239.67;
			case R.id.fedex:
				return 474.00;
			case R.id.estafeta:
				return 565.71;
			case R.id.redpack:
			case R.id.paquer:
			case R.id.paquete_express:
			case R.id.envia:
				return 239.67;
			case R.id.tresGuerras:
				return 180.30;
			case R.id.enviar:
				return 280.50;
			case R.id.fAmarilla:
				return 225.50;
			case R.id.button3:
				return 240.30;
			case R.id.odm:
				return 150.20;
			}

		}
		return 0;
	}

	public void Volver(View v) {
		Intent volver = new Intent(this, Misenvios.class);
		startActivity(volver);
	}

	public int firstLetter(String x) {
		return Integer.parseInt(x.charAt(0) + "");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.cotizar, menu);
		return true;
	}

}
