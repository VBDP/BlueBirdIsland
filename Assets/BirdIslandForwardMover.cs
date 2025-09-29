using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

// UdonSharp script para mover una isla lentamente hacia adelante en línea recta.
// Instrucciones:
// 1) Añade este script al GameObject de la isla.
// 2) Ajusta "moveDirection" para definir la dirección (por defecto Z+).
// 3) Ajusta "speed" para una velocidad muy lenta.

[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class BirdIslandForwardMover : UdonSharpBehaviour
{
    [Header("Movimiento lineal lento")]
    [Tooltip("Dirección de movimiento en espacio mundial.")]
    public Vector3 moveDirection = new Vector3(0f, 0f, 1f); // por defecto hacia adelante (eje Z)

    [Tooltip("Velocidad en metros por segundo. Usa valores muy bajos, por ejemplo 0.01 para movimiento casi imperceptible.")]
    public float speed = 0.01f;

    [Tooltip("Suavizado opcional para evitar saltos (0 = instantáneo, 1 = muy suave).")]
    [Range(0f, 1f)]
    public float movementSmooth = 0.05f;

    public bool smoothMovement = true;

    private Vector3 velocityPos = Vector3.zero;

    void Update()
    {
        // Dirección normalizada para evitar que la magnitud altere la velocidad
        Vector3 direction = moveDirection.normalized;
        Vector3 targetPos = transform.position + direction * speed * Time.deltaTime;

        if (smoothMovement)
        {
            transform.position = Vector3.SmoothDamp(transform.position, targetPos, ref velocityPos, movementSmooth);
        }
        else
        {
            transform.position = targetPos;
        }
    }
}
