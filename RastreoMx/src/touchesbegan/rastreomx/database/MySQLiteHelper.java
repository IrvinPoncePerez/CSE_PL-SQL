package touchesbegan.rastreomx.database;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class MySQLiteHelper extends SQLiteOpenHelper {
	public static final String TABLE_PAQUETES = "paquetes";

	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_CLAVE = "clave";
	public static final String COLUMN_ORIGEN = "origen";
	public static final String COLUMN_DESTINO = "destino";
	public static final String COLUMN_FECHA = "fecha";
	public static final String COLUMN_SITUACION = "situacion";
	public static final String COLUMN_RECIBIO = "recibio";
	public static final String COLUMN_PAQUETERIA ="paqueteria";

	public static final String DATABASE_NAME = "paquetes.db";
	public static final int DATABASE_VERSION = 3;

	public static final String DATABASE_CREATE = "create table "
			+ TABLE_PAQUETES + "(" + COLUMN_ID
			+ " integer primary key autoincrement, " 
			+ COLUMN_CLAVE + " text, "
			+ COLUMN_PAQUETERIA + " text, "
			+ COLUMN_ORIGEN + " text, " + COLUMN_DESTINO + " text, "
			+ COLUMN_FECHA + " text, " + COLUMN_SITUACION + " text, "
			+ COLUMN_RECIBIO + " text)";

	public MySQLiteHelper(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(DATABASE_CREATE);

	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		Log.w(MySQLiteHelper.class.getName(),
				"Upgrading database from version " + oldVersion + " to "
						+ newVersion + ", which will destroy all old data");
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_PAQUETES);
		onCreate(db);
	}

	public List<Paquete> verTodos() {
		SQLiteDatabase db = getReadableDatabase();
		List<Paquete> paquetes = new ArrayList<Paquete>();
		String[] valores = { "_id", COLUMN_CLAVE,COLUMN_PAQUETERIA, COLUMN_ORIGEN,
				COLUMN_DESTINO, COLUMN_FECHA, COLUMN_SITUACION, COLUMN_RECIBIO };
		Cursor c = db.query(TABLE_PAQUETES, valores, null, null, null, null,
				null, null);
		c.moveToFirst();
		while (!c.isAfterLast()) {
			Paquete paquete = cursorToComment(c);
			paquetes.add(paquete);
			c.moveToNext();
		}
		c.close();
		db.close();
		return paquetes;
	}
	private Paquete cursorToComment(Cursor cursor){
		Paquete paquete= new Paquete();
		paquete.setClave(cursor.getString(1));
		paquete.setPaqueteria(cursor.getString(2));
		paquete.setOrigen(cursor.getString(3));
		paquete.setDestino(cursor.getString(4));
		paquete.setFecha(cursor.getString(5));
		paquete.setSituacion(cursor.getString(6));
		paquete.setQuien(cursor.getString(7));
		return paquete;
	}

	public void insertaPaquete(String clave,String paqueteria, String origen, String destino,
			String fecha, String situacion, String recibio) {
		SQLiteDatabase db = getWritableDatabase();
		if (db != null) {
			ContentValues values = new ContentValues();
			values.put(COLUMN_CLAVE, clave);
			values.put(COLUMN_PAQUETERIA, paqueteria);
			/*values.put(COLUMN_ORIGEN, origen);
			values.put(COLUMN_DESTINO, destino);
			values.put(COLUMN_FECHA, fecha);
			values.put(COLUMN_SITUACION, situacion);
			values.put(COLUMN_RECIBIO, recibio);*/
			db.insert(TABLE_PAQUETES, null, values);
		}
	}
	public void deleteAll(){
		SQLiteDatabase db = getWritableDatabase();
	    db.delete(TABLE_PAQUETES, null, null);
	    db.close();  
	}
}
