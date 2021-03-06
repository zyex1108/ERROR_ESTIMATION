//
// C++ Interface: Calcul_error_estimate_prolongation_condition_homog
//
// Description: calcul d'un champ de contrainte admissible et d'un estimateur theta de l'erreur globale pour les methodes basees sur la condition de prolongement (EET,EESPT)
//
//
// Author: Pled Florent <pled@lmt.ens-cachan.fr>, (C) 2015
//
// Copyright: See COPYING file that comes with this distribution
//
//
#ifndef Calcul_error_estimate_prolongation_condition_homog_h
#define Calcul_error_estimate_prolongation_condition_homog_h

#include "ECRE.h"
#include "../DISCRETIZATION_ERROR/Discretization_error.h"

using namespace LMT;
using namespace std;

/// Construction d'un champ de contrainte admissible et Calcul d'un estimateur d'erreur globale pour les methodes basees sur la condition de prolongement (EET,EESPT)
/// -----------------------------------------------------------------------------------------------------------------------------------------------------------------
template<class TM, class TF, class T>
void calcul_error_estimate_prolongation_condition( TM &m, const TF &f, const string &pb, const string &method, T &theta, T &theta_init, Vec<T> &theta_elem, Vec<T> &theta_elem_init, const Vec< Vec<T> > &dep_hat, const bool want_global_discretization_error = false, const bool want_local_discretization_error = false, const bool disp = false ) {
    
    /// ------------------------------------------------------------------------------------------------------- ///
    /// Construction d'un champ de contrainte admissible par element et Calcul d'un estimateur d'erreur globale ///
    /// ------------------------------------------------------------------------------------------------------- ///
    
    if ( disp ) {
        cout << "Construction d'un champ de contrainte admissible par element et Calcul d'un estimateur d'erreur globale" << endl;
        cout << "-------------------------------------------------------------------------------------------------------" << endl << endl;
    }

    theta = 0.;
    theta_init = 0.;
    theta_elem.resize( m.elem_list.size() );
    theta_elem.set( 0. );
    theta_elem_init.resize( m.elem_list.size() );
    theta_elem_init.set( 0. );

    Calc_Elem_Error_Estimate_Init_EET_EESPT<T> calc_elem_error_estimate_init_EET_EESPT;
    calc_elem_error_estimate_init_EET_EESPT.dep_hat = &dep_hat;
    calc_elem_error_estimate_init_EET_EESPT.method = &method;
    calc_elem_error_estimate_init_EET_EESPT.theta_elem = &theta_elem;
    calc_elem_error_estimate_init_EET_EESPT.theta_elem_init = &theta_elem_init;
    calc_elem_error_estimate_init_EET_EESPT.theta_init = &theta_init;

    apply( m.elem_list, calc_elem_error_estimate_init_EET_EESPT, m, f, theta );

    if ( disp ) {
        for (unsigned n=0;n<m.elem_list.size();++n) {
            T ecre_elem = theta_elem[ n ] / 2.;
            T ecre_elem_init = theta_elem_init[ n ] / 2.;
            cout << "contribution a la mesure globale de l'erreur en relation de comportement au carre de l'element " << n << " :" << endl;
            cout << "ecre_elem^2 = " << ecre_elem << endl;
            cout << "ecre_elem_init^2 = " << ecre_elem_init << endl;

            cout << "contribution a l'estimateur d'erreur globale au carre de l'element " << n << " :" << endl;
            cout << "theta_elem^2 = " << theta_elem[ n ] << endl;
            cout << "theta_elem_init^2 = " << theta_elem_init[ n ] << endl;
        }
        cout << endl;
    }

    T ecre = theta / 2.;
    T ecre_init = theta_init / 2.;
//    cout << "mesure globale de l'erreur en relation de comportement au carre :" << endl;
//    cout << "ecre^2 = " << ecre << endl;
//    cout << "ecre_init^2 = " << ecre_init << endl << endl;

    ecre = sqrt( ecre );
    theta = sqrt( theta );

    ecre_init = sqrt( ecre_init );
    theta_init = sqrt( theta_init );
    if ( method == "EET" ) {
        m.ecre_EET = ecre;
        m.theta_EET = theta;

        m.ecre_init_EET = ecre_init;
        m.theta_init_EET = theta_init;
    }
    if ( method == "EESPT" ) {
        m.ecre_EESPT = ecre;
        m.theta_EESPT = theta;

        m.ecre_init_EESPT = ecre_init;
        m.theta_init_EESPT = theta_init;
    }
    cout << "mesure globale de l'erreur en relation de comportement :" << endl;
    cout << "ecre = " << ecre << endl;
    cout << "ecre_init = " << ecre_init << endl << endl;

    cout << "estimateur d'erreur globale :" << endl;
    cout << "theta = " << theta << endl;
    cout << "theta_init = " << theta_init << endl;
    cout << "theta / norm(u_h) = " << theta / m.norm_dep * 100. << " %" << endl;
    cout << "theta_init / norm(u_h)_init = " << theta_init / m.norm_dep_init * 100. << " %" << endl << endl;

    if ( pb == "direct" and want_global_discretization_error ) {
        T eff_index = theta / m.discretization_error;
        if ( method == "EET" )
            m.eff_index_EET = eff_index;
        if ( method == "EESPT" )
            m.eff_index_EESPT = eff_index;
        cout << "indice d'efficacite global :" << endl;
        cout << "eta = theta / e" << endl;
        cout << "    = " << eff_index << endl << endl;
    }

    if ( pb == "direct" and want_local_discretization_error ) {
        Vec<T> eff_index_elem;
        eff_index_elem.resize( m.elem_list.size(), 0. );
        eff_index_elem.set( 0. );

        apply( m.elem_list, Calcul_Elem_Effectivity_Index(), method, eff_index_elem );

        if ( disp ) {
            for (unsigned n=0;n<m.elem_list.size();++n) {
                cout << "indice d'efficacite local de l'element " << n << " :" << endl;
                cout << "eta_elem = theta_elem / e_elem" << endl;
                cout << "         = " << eff_index_elem[ n ] << endl;
            }
            cout << endl;
        }
    }
}

#endif // Calcul_error_estimate_prolongation_condition_homog_h
