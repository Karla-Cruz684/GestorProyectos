/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package codigos;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 *
 * @author Surface Book 2
 */

public class CRUD {

    private final Conexion con;

    public CRUD(Conexion con) {
        this.con = con;
    }
    
    public void cerrarConexion(){
        con.cerrar();
    }
    
    public String altaParticipante(String nombre, String apellidoP, String apellidoM, String usuario, String cargo) throws SQLException{
        String proceso = "call altaParticipante('" + nombre + "','" + apellidoP + "','" + apellidoM + "','" + usuario + "','" + cargo + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public String altaProyecto(String nombre, String objetivo, String fecha_inicio, String fecha_fin, String descripcion, String responsable) throws SQLException{
        String proceso = "call altaProyecto('" + nombre + "','" + objetivo + "','" + fecha_inicio + "','" + fecha_fin + "','" + descripcion + "','" + responsable + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public String altaTarea(String nombre, String fecha_inicio, String fecha_fin, String estado, String prioridad, String descripcion, String proyecto) throws SQLException{
        String proceso = "call altaTarea('" + nombre + "','" + fecha_inicio + "','" + fecha_fin + "','" + estado + "','" + prioridad + "','" + descripcion + "','" + proyecto + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public String asignarTarea(int id_tarea, int id_participante) throws SQLException{
        String proceso = "call asignarTarea('" + id_tarea + "','" + id_participante + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public String asignarPrecedenciaTarea(int id_tarea1, int id_tarea2) throws SQLException{
        String proceso = "call asignarPrecedenciaTarea('" + id_tarea1 + "','" + id_tarea2 + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public ArrayList<Object[]> participantes() throws SQLException{
        String proceso = "call participantes()";
        final ResultSet rs = con.call(proceso);
        ResultSetMetaData rsmd = (ResultSetMetaData)rs.getMetaData();
        ArrayList<Object[]> registros = new ArrayList<>();
        Object[] encabezado = new Object[rsmd.getColumnCount()];
        for (int i = 0; i < rsmd.getColumnCount(); i++) {
            encabezado[i] = rsmd.getColumnName(i+1);
        }
        registros.add(encabezado);
        while (rs.next()){            
            Object[] filas = new Object[rsmd.getColumnCount()];
            for (int i = 0; i < rsmd.getColumnCount(); i++) {
                filas[i] = rs.getObject(i+1);
            }
            registros.add(filas);
        }
        return registros;
    }
    
    public ArrayList<Object[]> tareas() throws SQLException{
        String proceso = "call tareas()";
        final ResultSet rs = con.call(proceso);
        ResultSetMetaData rsmd = (ResultSetMetaData)rs.getMetaData();
        ArrayList<Object[]> registros = new ArrayList<>();
        Object[] encabezado = new Object[rsmd.getColumnCount()];
        for (int i = 0; i < rsmd.getColumnCount(); i++) {
            encabezado[i] = rsmd.getColumnName(i+1);
        }
        registros.add(encabezado);
        while (rs.next()){            
            Object[] filas = new Object[rsmd.getColumnCount()];
            for (int i = 0; i < rsmd.getColumnCount(); i++) {
                filas[i] = rs.getObject(i+1);
            }
            registros.add(filas);
        }
        return registros;
    }
    
    public ArrayList<Object[]> proyectos() throws SQLException{
        String proceso = "call proyectos()";
        final ResultSet rs = con.call(proceso);
        ResultSetMetaData rsmd = (ResultSetMetaData)rs.getMetaData();
        ArrayList<Object[]> registros = new ArrayList<>();
        Object[] encabezado = new Object[rsmd.getColumnCount()];
        for (int i = 0; i < rsmd.getColumnCount(); i++) {
            encabezado[i] = rsmd.getColumnName(i+1);
        }
        registros.add(encabezado);
        while (rs.next()){            
            Object[] filas = new Object[rsmd.getColumnCount()];
            for (int i = 0; i < rsmd.getColumnCount(); i++) {
                filas[i] = rs.getObject(i+1);
            }
            registros.add(filas);
        }
        return registros;
    }
    
    
}
