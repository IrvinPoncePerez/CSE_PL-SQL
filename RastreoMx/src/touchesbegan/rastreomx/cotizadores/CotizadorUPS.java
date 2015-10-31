package touchesbegan.rastreomx.cotizadores;

public class CotizadorUPS {
	
	public CotizadorUPS() {

	}

	public double cotizar(int origen, int destino) {
		if ((origen == 0 && destino == 0) || (origen == 0 && destino == 1)
				|| (origen == 0 && destino == 6)
				|| (origen == 0 && destino == 4)
				|| (origen == 0 && destino == 4)
				|| (origen == 0 && destino == 5)
				|| (origen == 0 && destino == 6)
				|| (origen == 0 && destino == 7)
				|| (origen == 0 && destino == 9)
				|| (origen == 1 && destino == 0)
				|| (origen == 1 && destino == 6)
				|| (origen == 1 && destino == 4)
				|| (origen == 3 && destino == 3)
				|| (origen == 4 && destino == 1)
				|| (origen == 4 && destino == 0)
				|| (origen == 4 && destino == 6)
				|| (origen == 4 && destino == 0)
				|| (origen == 5 && destino == 1)
				|| (origen == 5 && destino == 0)
				|| (origen == 5 && destino == 5)
				|| (origen == 6 && destino == 0)
				|| (origen == 6 && destino == 4)
				|| (origen == 6 && destino == 0)
				|| (origen == 6 && destino == 1)
				|| (origen == 7 && destino == 0)
				|| (origen == 7 && destino == 7)
				|| (origen == 7 && destino == 1)
				|| (origen == 8 && destino == 0)
				|| (origen == 9 && destino == 0)) {
			return 238.50;
		}
		if ((origen == 0 && destino == 2) || (origen == 2 && destino == 0)
				|| (origen == 4 && destino == 4)
				|| (origen == 7 && destino == 3)
				|| (origen == 7 && destino == 5)
				|| (origen == 8 && destino == 2)) {
			return 278.50;
		}
		if ((origen == 1 && destino == 3) || (origen == 6 && destino == 3)
				|| (origen == 0 && destino == 3)
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
			return 316.60;
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
			return 255.60;
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
			return 235.50;
		}
		if ((origen == 0 && destino == 4) || (origen == 4 && destino == 0)
				|| (origen == 1 && destino == 3)
				|| (origen == 1 && destino == 4)
				|| (origen == 4 && destino == 1)
				|| (origen == 3 && destino == 1)) {
			return 246.70;
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
			return 331.30;
		}
		return 0;
	}
}
