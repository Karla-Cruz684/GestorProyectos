/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package codigos;

import com.mysql.jdbc.ResultSetMetaData;
import java.sql.SQLException;

/**
 *
 * @author Surface Book 2
 */

public class CRUD {

    private final Conexion con;

    public CRUD(Conexion con) {
        this.con = con;
    }
    
    public String altaParticipante(int id, String nombre) throws SQLException{
        String proceso = "call altaParticipante('" + id + "','" + nombre + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public String altaProyecto(int id, String nombre, String objetivo, String fecha_inicio, String fecha_fin, String descripcion, int responsable) throws SQLException{
        String proceso = "call altaProyecto('" + id + "','" + nombre + "','" + objetivo + "','" + fecha_inicio + "','" + fecha_fin + "','" + descripcion + "','" + responsable + "')";
        ResultSetMetaData resultado = (ResultSetMetaData)con.call(proceso).getMetaData();
        return resultado.toString();
    }
    
    public String altaTarea(int id, String nombre, String fecha_inicio, String fecha_fin, String Estado, String prioridad, String descripcion) throws SQLException{
        String proceso = "call altaTarea('" + id + "','" + nombre + "','" + fecha_inicio + "','" + fecha_fin + "','" + prioridad + "','" + descripcion + "')";
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
    
    
}
