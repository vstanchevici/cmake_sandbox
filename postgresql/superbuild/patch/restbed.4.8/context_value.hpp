/*
 * Copyright 2013-2020, Corvusoft Ltd, All Rights Reserved.
 */

#pragma once

//System Includes
#include <memory>
#include <ciso646>
#include <typeinfo>
#include <stdexcept>

//Project Includes
#include <corvusoft/restbed/context_placeholder.hpp>
#include <corvusoft/restbed/context_placeholder_base.hpp>

//External Includes

#define CONTEXT_VALUE_EXPORT

//System Namespaces

//Project Namespaces

//External Namespaces

namespace restbed
{
    //Forward Declarations
    
    class CONTEXT_VALUE_EXPORT ContextValue
    {
        public:
            //Friends
            
            //Definitions
            
            //Constructors
            template< typename Type >
            ContextValue( const Type& value ) : m_placeholder( new ContextPlaceholder< Type >( value ) )
            {
                return;
            }
            
            ContextValue( const ContextValue& original ) : m_placeholder( original.m_placeholder )
            {
                return;
            }
            
            virtual ~ContextValue( void )
            {
                return;
            }
            
            //Functionality
            
            //Getters
            
            //Setters
            
            //Operators
            template< typename Type > operator Type( void ) const
            {
                if ( typeid( Type ) not_eq m_placeholder->type( ) )
                {
                    throw std::bad_cast( );
                }
                
                auto placeholder = static_cast< ContextPlaceholder< Type >* >( m_placeholder.get( ) );
                return *placeholder;
            }
            
            //Properties
            
        protected:
            //Friends
            
            //Definitions
            
            //Constructors
            
            //Functionality
            
            //Getters
            
            //Setters
            
            //Operators
            
            //Properties
            
        private:
            //Friends
            
            //Definitions
            
            //Constructors
            ContextValue( void ) = delete;
            
            //Functionality
            
            //Getters
            
            //Setters
            
            //Operators
            ContextValue& operator =( const ContextValue& value ) = delete;
            
            //Properties
            const std::shared_ptr< ContextPlaceholderBase > m_placeholder;
    };
}
