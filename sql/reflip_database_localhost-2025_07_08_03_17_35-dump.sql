--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: reflip-database; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "reflip-database" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';


ALTER DATABASE "reflip-database" OWNER TO postgres;

\connect -reuse-previous=on "dbname='reflip-database'"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_browse_history_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_browse_history_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_browse_history_updated_at() OWNER TO postgres;

--
-- Name: update_rf_balance_detail_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_rf_balance_detail_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_rf_balance_detail_updated_at() OWNER TO postgres;

--
-- Name: update_updated_time_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_time_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_time_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chat_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_message (
    id bigint NOT NULL,
    sender_user_id bigint NOT NULL,
    receiver_user_id bigint NOT NULL,
    message_type character varying(50),
    message_content text,
    send_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50),
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    is_read boolean
);


ALTER TABLE public.chat_message OWNER TO postgres;

--
-- Name: chat_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_message_id_seq OWNER TO postgres;

--
-- Name: chat_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_message_id_seq OWNED BY public.chat_message.id;


--
-- Name: rf_balance_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_balance_detail (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    prev_detail_id bigint,
    next_detail_id bigint,
    transaction_type character varying(20) NOT NULL,
    amount numeric(15,2) NOT NULL,
    balance_before numeric(15,2) NOT NULL,
    balance_after numeric(15,2) NOT NULL,
    description character varying(500),
    transaction_time timestamp without time zone NOT NULL,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    CONSTRAINT chk_amount_positive CHECK ((amount <> (0)::numeric)),
    CONSTRAINT chk_balance_non_negative CHECK (((balance_before >= (0)::numeric) AND (balance_after >= (0)::numeric)))
);


ALTER TABLE public.rf_balance_detail OWNER TO postgres;

--
-- Name: TABLE rf_balance_detail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_balance_detail IS '用户余额明细表，采用双链表结构记录用户余额变动历史';


--
-- Name: COLUMN rf_balance_detail.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.id IS '主键';


--
-- Name: COLUMN rf_balance_detail.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.user_id IS '用户ID';


--
-- Name: COLUMN rf_balance_detail.prev_detail_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.prev_detail_id IS '上一个明细ID（双链表前指针）';


--
-- Name: COLUMN rf_balance_detail.next_detail_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.next_detail_id IS '下一个明细ID（双链表后指针）';


--
-- Name: COLUMN rf_balance_detail.transaction_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.transaction_type IS '交易类型：RECHARGE-充值，WITHDRAWAL-提现，CONSUMPTION-消费，REFUND-退款，COMMISSION-佣金收入，REWARD-平台奖励';


--
-- Name: COLUMN rf_balance_detail.amount; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.amount IS '交易金额';


--
-- Name: COLUMN rf_balance_detail.balance_before; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.balance_before IS '交易前余额';


--
-- Name: COLUMN rf_balance_detail.balance_after; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.balance_after IS '交易后余额';


--
-- Name: COLUMN rf_balance_detail.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.description IS '交易描述';


--
-- Name: COLUMN rf_balance_detail.transaction_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.transaction_time IS '交易时间';


--
-- Name: COLUMN rf_balance_detail.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.create_time IS '创建时间';


--
-- Name: COLUMN rf_balance_detail.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.update_time IS '更新时间';


--
-- Name: COLUMN rf_balance_detail.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_balance_detail.is_delete IS '是否删除';


--
-- Name: rf_balance_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_balance_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_balance_detail_id_seq OWNER TO postgres;

--
-- Name: rf_balance_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_balance_detail_id_seq OWNED BY public.rf_balance_detail.id;


--
-- Name: rf_bill_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_bill_item (
    id bigint NOT NULL,
    product_id bigint,
    product_sell_record_id bigint,
    cost_type character varying(50),
    cost_description text,
    cost numeric(10,2),
    pay_subject character varying(100),
    is_platform_pay boolean DEFAULT false,
    pay_user_id bigint,
    status character varying(50),
    pay_time timestamp without time zone,
    payment_record_id bigint,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.rf_bill_item OWNER TO postgres;

--
-- Name: rf_bill_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_bill_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_bill_item_id_seq OWNER TO postgres;

--
-- Name: rf_bill_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_bill_item_id_seq OWNED BY public.rf_bill_item.id;


--
-- Name: rf_internal_logistics_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_internal_logistics_task (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    task_type character varying(50),
    logistics_user_id bigint,
    source_address text,
    source_address_image_url_json text,
    target_address text,
    target_address_image_url_json text,
    logistics_cost numeric(10,2),
    status character varying(50),
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    product_consignment_record_id bigint,
    product_return_record_id bigint,
    product_return_to_seller_record_id bigint,
    contact_phone character varying
);


ALTER TABLE public.rf_internal_logistics_task OWNER TO postgres;

--
-- Name: rf_internal_logistics_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_internal_logistics_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_internal_logistics_task_id_seq OWNER TO postgres;

--
-- Name: rf_internal_logistics_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_internal_logistics_task_id_seq OWNED BY public.rf_internal_logistics_task.id;


--
-- Name: rf_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    category_id bigint,
    type character varying(255),
    price numeric(10,2),
    stock integer DEFAULT 0,
    description text,
    image_url_json text,
    is_auction boolean DEFAULT false,
    is_self_pickup boolean DEFAULT false,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    address character varying,
    category character varying(255),
    status character varying,
    user_id bigint NOT NULL,
    warehouse_id bigint,
    warehouse_stock_id bigint
);


ALTER TABLE public.rf_product OWNER TO postgres;

--
-- Name: COLUMN rf_product.warehouse_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product.warehouse_id IS '现存仓库ID';


--
-- Name: rf_product_auction_logistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_auction_logistics (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    pickup_address text,
    warehouse_id bigint,
    warehouse_address text,
    is_use_logistics_service boolean DEFAULT false,
    appointment_pickup_date date,
    internal_logistics_task_id bigint,
    external_logistics_service_name character varying(255),
    external_logistics_order_number character varying(255),
    status character varying(50) DEFAULT '待上门'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    appointment_pickup_time_period character varying,
    CONSTRAINT chk_auction_logistics_status CHECK (((status)::text = ANY (ARRAY[('PENDING_PICKUP'::character varying)::text, ('PENDING_WAREHOUSING'::character varying)::text, ('WAREHOUSED'::character varying)::text])))
);


ALTER TABLE public.rf_product_auction_logistics OWNER TO postgres;

--
-- Name: rf_product_auction_logistics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_auction_logistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_auction_logistics_id_seq OWNER TO postgres;

--
-- Name: rf_product_auction_logistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_auction_logistics_id_seq OWNED BY public.rf_product_auction_logistics.id;


--
-- Name: rf_product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_category (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.rf_product_category OWNER TO postgres;

--
-- Name: rf_product_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_category_id_seq OWNER TO postgres;

--
-- Name: rf_product_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_category_id_seq OWNED BY public.rf_product_category.id;


--
-- Name: rf_product_comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_comment (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    commenter_user_id bigint NOT NULL,
    comment_content text NOT NULL,
    seller_reply text,
    seller_reply_time timestamp without time zone,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    update_time timestamp without time zone DEFAULT now() NOT NULL,
    is_delete boolean DEFAULT false NOT NULL
);


ALTER TABLE public.rf_product_comment OWNER TO postgres;

--
-- Name: TABLE rf_product_comment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_product_comment IS '商品留言表';


--
-- Name: COLUMN rf_product_comment.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.id IS '主键';


--
-- Name: COLUMN rf_product_comment.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.product_id IS '商品ID';


--
-- Name: COLUMN rf_product_comment.commenter_user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.commenter_user_id IS '留言用户ID';


--
-- Name: COLUMN rf_product_comment.comment_content; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.comment_content IS '留言内容';


--
-- Name: COLUMN rf_product_comment.seller_reply; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.seller_reply IS '卖家回复';


--
-- Name: COLUMN rf_product_comment.seller_reply_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.seller_reply_time IS '卖家回复时间';


--
-- Name: COLUMN rf_product_comment.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.create_time IS '创建时间';


--
-- Name: COLUMN rf_product_comment.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.update_time IS '更新时间';


--
-- Name: COLUMN rf_product_comment.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_comment.is_delete IS '是否删除';


--
-- Name: rf_product_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_comment_id_seq OWNER TO postgres;

--
-- Name: rf_product_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_comment_id_seq OWNED BY public.rf_product_comment.id;


--
-- Name: rf_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_id_seq OWNER TO postgres;

--
-- Name: rf_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_id_seq OWNED BY public.rf_product.id;


--
-- Name: rf_product_non_consignment_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_non_consignment_info (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    seller_id bigint NOT NULL,
    delivery_method text NOT NULL,
    pickup_address text,
    pickup_address_detail text,
    buyer_receipt_address text,
    buyer_receipt_address_detail text,
    appointment_pickup_date date,
    appointment_pickup_time_period text,
    status text NOT NULL,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_delete boolean DEFAULT false NOT NULL
);


ALTER TABLE public.rf_product_non_consignment_info OWNER TO postgres;

--
-- Name: COLUMN rf_product_non_consignment_info.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.product_id IS '商品ID';


--
-- Name: COLUMN rf_product_non_consignment_info.seller_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.seller_id IS '卖家ID';


--
-- Name: COLUMN rf_product_non_consignment_info.delivery_method; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.delivery_method IS '送达方式';


--
-- Name: COLUMN rf_product_non_consignment_info.pickup_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.pickup_address IS '取货地址';


--
-- Name: COLUMN rf_product_non_consignment_info.pickup_address_detail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.pickup_address_detail IS '取货地址详细';


--
-- Name: COLUMN rf_product_non_consignment_info.buyer_receipt_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.buyer_receipt_address IS '收货地址';


--
-- Name: COLUMN rf_product_non_consignment_info.buyer_receipt_address_detail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.buyer_receipt_address_detail IS '收货地址详细';


--
-- Name: COLUMN rf_product_non_consignment_info.appointment_pickup_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.appointment_pickup_date IS '预约取货日期';


--
-- Name: COLUMN rf_product_non_consignment_info.appointment_pickup_time_period; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.appointment_pickup_time_period IS '预约取货时间段';


--
-- Name: COLUMN rf_product_non_consignment_info.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.status IS '状态';


--
-- Name: COLUMN rf_product_non_consignment_info.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.create_time IS '创建时间';


--
-- Name: COLUMN rf_product_non_consignment_info.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.update_time IS '更新时间';


--
-- Name: COLUMN rf_product_non_consignment_info.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_non_consignment_info.is_delete IS '是否删除';


--
-- Name: rf_product_non_consignment_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_non_consignment_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_non_consignment_info_id_seq OWNER TO postgres;

--
-- Name: rf_product_non_consignment_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_non_consignment_info_id_seq OWNED BY public.rf_product_non_consignment_info.id;


--
-- Name: rf_product_return_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_return_record (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint NOT NULL,
    return_reason_type character varying(100),
    return_reason_detail text,
    audit_result character varying(50),
    audit_detail text,
    freight_bearer character varying(50),
    freight_bearer_user_id bigint,
    need_compensate_product boolean,
    compensation_bearer character varying(50),
    compensation_bearer_user_id bigint,
    is_auction boolean DEFAULT false,
    is_use_logistics_service boolean DEFAULT false,
    appointment_pickup_time timestamp without time zone,
    internal_logistics_task_id bigint,
    external_logistics_service_name character varying(255),
    external_logistics_order_number character varying(255),
    status character varying(50) DEFAULT '发起退货'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    seller_accept_return boolean,
    seller_opinion_detail character varying,
    pickup_address character varying
);


ALTER TABLE public.rf_product_return_record OWNER TO postgres;

--
-- Name: rf_product_return_record_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_return_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_return_record_id_seq OWNER TO postgres;

--
-- Name: rf_product_return_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_return_record_id_seq OWNED BY public.rf_product_return_record.id;


--
-- Name: rf_product_return_to_seller; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_return_to_seller (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    warehouse_id bigint NOT NULL,
    warehouse_address text NOT NULL,
    seller_receipt_address text NOT NULL,
    internal_logistics_task_id bigint,
    shipment_time timestamp without time zone,
    shipment_image_url_json text,
    status character varying(20) NOT NULL,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    update_time timestamp without time zone DEFAULT now() NOT NULL,
    is_delete boolean DEFAULT false NOT NULL
);


ALTER TABLE public.rf_product_return_to_seller OWNER TO postgres;

--
-- Name: TABLE rf_product_return_to_seller; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_product_return_to_seller IS '商品退回卖家记录表';


--
-- Name: COLUMN rf_product_return_to_seller.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.id IS '主键';


--
-- Name: COLUMN rf_product_return_to_seller.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.product_id IS '商品ID';


--
-- Name: COLUMN rf_product_return_to_seller.product_sell_record_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.product_sell_record_id IS '商品出售记录ID';


--
-- Name: COLUMN rf_product_return_to_seller.warehouse_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.warehouse_id IS '仓库ID';


--
-- Name: COLUMN rf_product_return_to_seller.warehouse_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.warehouse_address IS '仓库地址';


--
-- Name: COLUMN rf_product_return_to_seller.seller_receipt_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.seller_receipt_address IS '卖家收货地址';


--
-- Name: COLUMN rf_product_return_to_seller.internal_logistics_task_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.internal_logistics_task_id IS '内部物流任务ID';


--
-- Name: COLUMN rf_product_return_to_seller.shipment_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.shipment_time IS '发货时间';


--
-- Name: COLUMN rf_product_return_to_seller.shipment_image_url_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.shipment_image_url_json IS '发货时货件图片集';


--
-- Name: COLUMN rf_product_return_to_seller.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.status IS '状态';


--
-- Name: COLUMN rf_product_return_to_seller.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.create_time IS '创建时间';


--
-- Name: COLUMN rf_product_return_to_seller.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.update_time IS '更新时间';


--
-- Name: COLUMN rf_product_return_to_seller.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_product_return_to_seller.is_delete IS '是否删除';


--
-- Name: rf_product_return_to_seller_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_return_to_seller_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_return_to_seller_id_seq OWNER TO postgres;

--
-- Name: rf_product_return_to_seller_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_return_to_seller_id_seq OWNED BY public.rf_product_return_to_seller.id;


--
-- Name: rf_product_self_pickup_logistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_self_pickup_logistics (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint NOT NULL,
    pickup_address text,
    buyer_receipt_address text,
    external_logistics_service_name character varying(255),
    external_logistics_order_number character varying(255),
    status character varying(50) DEFAULT '已发货'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    CONSTRAINT chk_self_pickup_logistics_status CHECK (((status)::text = ANY ((ARRAY['已发货'::character varying, '已签收'::character varying])::text[])))
);


ALTER TABLE public.rf_product_self_pickup_logistics OWNER TO postgres;

--
-- Name: rf_product_self_pickup_logistics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_self_pickup_logistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_self_pickup_logistics_id_seq OWNER TO postgres;

--
-- Name: rf_product_self_pickup_logistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_self_pickup_logistics_id_seq OWNED BY public.rf_product_self_pickup_logistics.id;


--
-- Name: rf_product_sell_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_sell_record (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    seller_user_id bigint NOT NULL,
    buyer_user_id bigint,
    final_product_price numeric(10,2),
    is_auction boolean DEFAULT false,
    product_warehouse_shipment_id bigint,
    is_self_pickup boolean DEFAULT false,
    product_self_pickup_logistics_id bigint,
    buyer_receipt_image_url_json text,
    seller_return_image_url_json text,
    status character varying(50) DEFAULT '待发货'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    internal_logistics_task_id bigint
);


ALTER TABLE public.rf_product_sell_record OWNER TO postgres;

--
-- Name: rf_product_sell_record_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_sell_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_sell_record_id_seq OWNER TO postgres;

--
-- Name: rf_product_sell_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_sell_record_id_seq OWNED BY public.rf_product_sell_record.id;


--
-- Name: rf_product_warehouse_shipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_product_warehouse_shipment (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    warehouse_address text,
    buyer_receipt_address text,
    shipment_time timestamp without time zone,
    internal_logistics_task_id bigint,
    shipment_image_url_json text,
    status character varying(50) DEFAULT '待出库'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    CONSTRAINT chk_warehouse_shipment_status CHECK (((status)::text = ANY ((ARRAY['待出库'::character varying, '待收货'::character varying, '已签收'::character varying])::text[])))
);


ALTER TABLE public.rf_product_warehouse_shipment OWNER TO postgres;

--
-- Name: rf_product_warehouse_shipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_product_warehouse_shipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_product_warehouse_shipment_id_seq OWNER TO postgres;

--
-- Name: rf_product_warehouse_shipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_product_warehouse_shipment_id_seq OWNED BY public.rf_product_warehouse_shipment.id;


--
-- Name: rf_purchase_review; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_purchase_review (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint NOT NULL,
    reviewer_user_id bigint NOT NULL,
    rating integer,
    review_content text,
    review_images_json text,
    seller_reply text,
    seller_reply_time timestamp without time zone,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    update_time timestamp without time zone DEFAULT now() NOT NULL,
    is_delete boolean DEFAULT false NOT NULL,
    seller_user_id bigint NOT NULL,
    CONSTRAINT rf_purchase_review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.rf_purchase_review OWNER TO postgres;

--
-- Name: TABLE rf_purchase_review; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_purchase_review IS '购买评价表';


--
-- Name: COLUMN rf_purchase_review.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.id IS '主键';


--
-- Name: COLUMN rf_purchase_review.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.product_id IS '商品ID';


--
-- Name: COLUMN rf_purchase_review.product_sell_record_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.product_sell_record_id IS '商品出售记录ID';


--
-- Name: COLUMN rf_purchase_review.reviewer_user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.reviewer_user_id IS '评价用户ID';


--
-- Name: COLUMN rf_purchase_review.rating; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.rating IS '评分(1-5)';


--
-- Name: COLUMN rf_purchase_review.review_content; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.review_content IS '评价内容';


--
-- Name: COLUMN rf_purchase_review.review_images_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.review_images_json IS '评价图片集';


--
-- Name: COLUMN rf_purchase_review.seller_reply; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.seller_reply IS '卖家回复';


--
-- Name: COLUMN rf_purchase_review.seller_reply_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.seller_reply_time IS '卖家回复时间';


--
-- Name: COLUMN rf_purchase_review.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.create_time IS '创建时间';


--
-- Name: COLUMN rf_purchase_review.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.update_time IS '更新时间';


--
-- Name: COLUMN rf_purchase_review.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_purchase_review.is_delete IS '是否删除';


--
-- Name: rf_purchase_review_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_purchase_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_purchase_review_id_seq OWNER TO postgres;

--
-- Name: rf_purchase_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_purchase_review_id_seq OWNED BY public.rf_purchase_review.id;


--
-- Name: rf_user_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_user_address (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    receiver_name character varying(50) NOT NULL,
    receiver_phone character varying(20) NOT NULL,
    region character varying(255) NOT NULL,
    is_default boolean DEFAULT false,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.rf_user_address OWNER TO postgres;

--
-- Name: TABLE rf_user_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_user_address IS '用户地址表';


--
-- Name: COLUMN rf_user_address.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.id IS '主键';


--
-- Name: COLUMN rf_user_address.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.user_id IS '用户ID';


--
-- Name: COLUMN rf_user_address.receiver_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.receiver_name IS '收货人姓名';


--
-- Name: COLUMN rf_user_address.receiver_phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.receiver_phone IS '收货人电话';


--
-- Name: COLUMN rf_user_address.region; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.region IS '地区';


--
-- Name: COLUMN rf_user_address.is_default; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.is_default IS '是否默认地址';


--
-- Name: COLUMN rf_user_address.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.create_time IS '创建时间';


--
-- Name: COLUMN rf_user_address.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.update_time IS '更新时间';


--
-- Name: COLUMN rf_user_address.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_address.is_delete IS '是否删除';


--
-- Name: rf_user_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_user_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_user_address_id_seq OWNER TO postgres;

--
-- Name: rf_user_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_user_address_id_seq OWNED BY public.rf_user_address.id;


--
-- Name: rf_user_favorite_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_user_favorite_product (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    favorite_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.rf_user_favorite_product OWNER TO postgres;

--
-- Name: TABLE rf_user_favorite_product; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_user_favorite_product IS '用户收藏商品表';


--
-- Name: COLUMN rf_user_favorite_product.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_favorite_product.id IS '主键';


--
-- Name: COLUMN rf_user_favorite_product.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_favorite_product.user_id IS '用户ID';


--
-- Name: COLUMN rf_user_favorite_product.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_favorite_product.product_id IS '商品ID';


--
-- Name: COLUMN rf_user_favorite_product.favorite_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_favorite_product.favorite_time IS '收藏时间';


--
-- Name: rf_user_favorite_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_user_favorite_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_user_favorite_product_id_seq OWNER TO postgres;

--
-- Name: rf_user_favorite_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_user_favorite_product_id_seq OWNED BY public.rf_user_favorite_product.id;


--
-- Name: rf_user_product_browse_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_user_product_browse_history (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    browse_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_delete boolean DEFAULT false NOT NULL,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.rf_user_product_browse_history OWNER TO postgres;

--
-- Name: TABLE rf_user_product_browse_history; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.rf_user_product_browse_history IS '用户商品浏览记录表';


--
-- Name: COLUMN rf_user_product_browse_history.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.id IS '主键';


--
-- Name: COLUMN rf_user_product_browse_history.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.user_id IS '用户ID';


--
-- Name: COLUMN rf_user_product_browse_history.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.product_id IS '商品ID';


--
-- Name: COLUMN rf_user_product_browse_history.browse_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.browse_time IS '浏览时间';


--
-- Name: COLUMN rf_user_product_browse_history.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.is_delete IS '是否删除';


--
-- Name: COLUMN rf_user_product_browse_history.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.create_time IS '创建时间';


--
-- Name: COLUMN rf_user_product_browse_history.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.rf_user_product_browse_history.update_time IS '更新时间';


--
-- Name: rf_user_product_browse_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_user_product_browse_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_user_product_browse_history_id_seq OWNER TO postgres;

--
-- Name: rf_user_product_browse_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_user_product_browse_history_id_seq OWNED BY public.rf_user_product_browse_history.id;


--
-- Name: rf_warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_warehouse (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    address text,
    monthly_warehouse_cost numeric(10,2),
    status character varying(50) DEFAULT 'ENABLED'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    CONSTRAINT chk_warehouse_status CHECK (((status)::text = ANY (ARRAY[('ENABLED'::character varying)::text, ('DISABLED'::character varying)::text])))
);


ALTER TABLE public.rf_warehouse OWNER TO postgres;

--
-- Name: rf_warehouse_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_warehouse_cost (
    id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    cost_type character varying(100),
    cost numeric(10,2),
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.rf_warehouse_cost OWNER TO postgres;

--
-- Name: rf_warehouse_cost_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_warehouse_cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_warehouse_cost_id_seq OWNER TO postgres;

--
-- Name: rf_warehouse_cost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_warehouse_cost_id_seq OWNED BY public.rf_warehouse_cost.id;


--
-- Name: rf_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_warehouse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_warehouse_id_seq OWNER TO postgres;

--
-- Name: rf_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_warehouse_id_seq OWNED BY public.rf_warehouse.id;


--
-- Name: rf_warehouse_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_warehouse_in (
    id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    in_quantity integer DEFAULT 1,
    in_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    stock_position character varying(255),
    product_image_url_json text,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.rf_warehouse_in OWNER TO postgres;

--
-- Name: rf_warehouse_in_apply; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_warehouse_in_apply (
    id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    source character varying(50),
    apply_quantity integer DEFAULT 1,
    apply_time timestamp without time zone,
    product_image_url_json text,
    audit_result character varying(50),
    audit_detail text,
    status character varying(50) DEFAULT '待审批'::character varying,
    warehouse_in_id bigint,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    product_consignment_record_id bigint,
    product_return_record_id bigint,
    product_return_to_seller_record_id bigint,
    CONSTRAINT chk_warehouse_in_apply_audit_result CHECK (((audit_result)::text = ANY ((ARRAY['批准入库'::character varying, '拒绝入库'::character varying])::text[]))),
    CONSTRAINT chk_warehouse_in_apply_source CHECK (((source)::text = ANY ((ARRAY['卖方寄卖'::character varying, '买房退货'::character varying])::text[]))),
    CONSTRAINT chk_warehouse_in_apply_status CHECK (((status)::text = ANY ((ARRAY['待审批'::character varying, '已审批'::character varying])::text[])))
);


ALTER TABLE public.rf_warehouse_in_apply OWNER TO postgres;

--
-- Name: rf_warehouse_in_apply_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_warehouse_in_apply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_warehouse_in_apply_id_seq OWNER TO postgres;

--
-- Name: rf_warehouse_in_apply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_warehouse_in_apply_id_seq OWNED BY public.rf_warehouse_in_apply.id;


--
-- Name: rf_warehouse_in_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_warehouse_in_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_warehouse_in_id_seq OWNER TO postgres;

--
-- Name: rf_warehouse_in_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_warehouse_in_id_seq OWNED BY public.rf_warehouse_in.id;


--
-- Name: rf_warehouse_out; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_warehouse_out (
    id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_sell_record_id bigint,
    stock_position character varying(255),
    out_quantity integer DEFAULT 1,
    out_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    product_image_url_json text,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.rf_warehouse_out OWNER TO postgres;

--
-- Name: rf_warehouse_out_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_warehouse_out_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_warehouse_out_id_seq OWNER TO postgres;

--
-- Name: rf_warehouse_out_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_warehouse_out_id_seq OWNED BY public.rf_warehouse_out.id;


--
-- Name: rf_warehouse_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rf_warehouse_stock (
    id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    product_id bigint NOT NULL,
    stock_quantity integer DEFAULT 0,
    stock_position character varying(255),
    warehouse_in_apply_id bigint,
    warehouse_in_id bigint,
    in_time timestamp without time zone,
    warehouse_out_id bigint,
    out_time timestamp without time zone,
    status character varying(50) DEFAULT '库存中'::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_delete boolean DEFAULT false,
    in_type character varying,
    out_type character varying
);


ALTER TABLE public.rf_warehouse_stock OWNER TO postgres;

--
-- Name: rf_warehouse_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rf_warehouse_stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rf_warehouse_stock_id_seq OWNER TO postgres;

--
-- Name: rf_warehouse_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rf_warehouse_stock_id_seq OWNED BY public.rf_warehouse_stock.id;


--
-- Name: sys_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_menu (
    id integer NOT NULL,
    menu_name character varying NOT NULL,
    parent_id bigint DEFAULT 0,
    order_num integer DEFAULT 0,
    path character varying DEFAULT ''::character varying,
    component character varying,
    query character varying,
    route_name character varying DEFAULT ''::character varying,
    is_frame integer DEFAULT 1,
    is_cache integer DEFAULT 0,
    menu_type character(1) DEFAULT ''::bpchar,
    visible character(1) DEFAULT '0'::bpchar,
    status character(1) DEFAULT '0'::bpchar,
    perms character varying,
    icon character varying DEFAULT '#'::character varying,
    create_by character varying DEFAULT ''::character varying,
    create_time timestamp without time zone,
    update_by character varying DEFAULT ''::character varying,
    update_time timestamp without time zone,
    remark character varying DEFAULT ''::character varying
);


ALTER TABLE public.sys_menu OWNER TO postgres;

--
-- Name: TABLE sys_menu; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sys_menu IS '菜单表';


--
-- Name: COLUMN sys_menu.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.id IS '菜单id';


--
-- Name: COLUMN sys_menu.menu_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.menu_name IS '菜单名称';


--
-- Name: COLUMN sys_menu.parent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.parent_id IS '父菜单id';


--
-- Name: COLUMN sys_menu.order_num; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.order_num IS '排序';


--
-- Name: COLUMN sys_menu.path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.path IS '路由地址';


--
-- Name: COLUMN sys_menu.component; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.component IS '组件路径';


--
-- Name: COLUMN sys_menu.query; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.query IS '路由参数';


--
-- Name: COLUMN sys_menu.route_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.route_name IS '路由名称';


--
-- Name: COLUMN sys_menu.is_frame; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.is_frame IS '是否外链（0是 1否）';


--
-- Name: COLUMN sys_menu.is_cache; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.is_cache IS '是否缓存（0缓存 1不缓存）';


--
-- Name: COLUMN sys_menu.menu_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.menu_type IS '菜单类型（M目录 C菜单 F按钮）';


--
-- Name: COLUMN sys_menu.visible; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.visible IS '菜单状态（0显示 1隐藏）';


--
-- Name: COLUMN sys_menu.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.status IS '菜单状态（0正常 1停用）';


--
-- Name: COLUMN sys_menu.perms; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.perms IS '权限标识';


--
-- Name: COLUMN sys_menu.icon; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.icon IS '菜单图标';


--
-- Name: COLUMN sys_menu.create_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.create_by IS '创建者';


--
-- Name: COLUMN sys_menu.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.create_time IS '创建时间';


--
-- Name: COLUMN sys_menu.update_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.update_by IS '更新者';


--
-- Name: COLUMN sys_menu.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.update_time IS '更新时间';


--
-- Name: COLUMN sys_menu.remark; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_menu.remark IS '备注';


--
-- Name: sys_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_menu_id_seq OWNER TO postgres;

--
-- Name: sys_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_menu_id_seq OWNED BY public.sys_menu.id;


--
-- Name: sys_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_role (
    id integer NOT NULL,
    key character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.sys_role OWNER TO postgres;

--
-- Name: TABLE sys_role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sys_role IS '角色表';


--
-- Name: COLUMN sys_role.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_role.id IS '角色id';


--
-- Name: COLUMN sys_role.key; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_role.key IS '角色键';


--
-- Name: COLUMN sys_role.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_role.name IS '角色名称';


--
-- Name: sys_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_role_id_seq OWNER TO postgres;

--
-- Name: sys_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_role_id_seq OWNED BY public.sys_role.id;


--
-- Name: sys_role_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_role_menu (
    role_id integer NOT NULL,
    menu_id integer NOT NULL
);


ALTER TABLE public.sys_role_menu OWNER TO postgres;

--
-- Name: TABLE sys_role_menu; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sys_role_menu IS '角色菜单关联表';


--
-- Name: COLUMN sys_role_menu.role_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_role_menu.role_id IS '角色id';


--
-- Name: COLUMN sys_role_menu.menu_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_role_menu.menu_id IS '菜单id';


--
-- Name: sys_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_user (
    id integer NOT NULL,
    username character varying NOT NULL,
    password character varying,
    role_id integer,
    wechat_open_id character varying,
    avatar character varying,
    nickname character varying,
    email character varying,
    phone_number character varying,
    sex character varying DEFAULT 'unset'::character varying,
    last_login_ip character varying,
    last_login_date timestamp without time zone,
    create_by character varying,
    create_time timestamp without time zone,
    update_by character varying,
    update_time timestamp without time zone,
    is_delete boolean DEFAULT false,
    client_role character varying DEFAULT '用户'::character varying,
    google_sub character varying(255),
    google_linked_time timestamp without time zone,
    apple_sub character varying(255),
    apple_linked_time timestamp without time zone
);


ALTER TABLE public.sys_user OWNER TO postgres;

--
-- Name: TABLE sys_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sys_user IS '用户表';


--
-- Name: COLUMN sys_user.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.id IS '用户id';


--
-- Name: COLUMN sys_user.username; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.username IS '用户名';


--
-- Name: COLUMN sys_user.password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.password IS '密码';


--
-- Name: COLUMN sys_user.role_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.role_id IS '角色id';


--
-- Name: COLUMN sys_user.nickname; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.nickname IS '昵称';


--
-- Name: COLUMN sys_user.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.email IS '邮箱';


--
-- Name: COLUMN sys_user.phone_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.phone_number IS '手机号';


--
-- Name: COLUMN sys_user.sex; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.sex IS '性别';


--
-- Name: COLUMN sys_user.last_login_ip; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.last_login_ip IS '最后登录ip';


--
-- Name: COLUMN sys_user.last_login_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user.last_login_date IS '最后登录时间';


--
-- Name: sys_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_user_id_seq OWNER TO postgres;

--
-- Name: sys_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_user_id_seq OWNED BY public.sys_user.id;


--
-- Name: sys_user_stripe_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_user_stripe_account (
    id integer NOT NULL,
    user_id integer NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    account_status character varying(50),
    verification_status character varying(50),
    capabilities_json text,
    requirements_json text,
    account_link_url character varying(512),
    link_expires_at timestamp without time zone,
    can_receive_payments boolean DEFAULT false,
    can_make_transfers boolean DEFAULT false,
    last_sync_time timestamp without time zone,
    is_delete boolean DEFAULT false
);


ALTER TABLE public.sys_user_stripe_account OWNER TO postgres;

--
-- Name: TABLE sys_user_stripe_account; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.sys_user_stripe_account IS '用户 Stripe Express 账户信息表（仅存长期有效字段）';


--
-- Name: COLUMN sys_user_stripe_account.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.id IS '自增主键';


--
-- Name: COLUMN sys_user_stripe_account.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.user_id IS '关联的 sys_user.id，一对一';


--
-- Name: COLUMN sys_user_stripe_account.stripe_account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.stripe_account_id IS 'Stripe Express Account ID，如 acct_ABC123';


--
-- Name: COLUMN sys_user_stripe_account.create_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.create_time IS '记录创建时间';


--
-- Name: COLUMN sys_user_stripe_account.update_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.update_time IS '记录最后更新时间';


--
-- Name: COLUMN sys_user_stripe_account.account_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.account_status IS '账户状态: pending, active, restricted';


--
-- Name: COLUMN sys_user_stripe_account.verification_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.verification_status IS '验证状态: unverified, pending, verified';


--
-- Name: COLUMN sys_user_stripe_account.capabilities_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.capabilities_json IS '账户能力状态 JSON: card_payments、transfers 等';


--
-- Name: COLUMN sys_user_stripe_account.requirements_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.requirements_json IS '待完成要求 JSON: Stripe requirements 信息';


--
-- Name: COLUMN sys_user_stripe_account.account_link_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.account_link_url IS 'Stripe 托管账户设置/入驻链接';


--
-- Name: COLUMN sys_user_stripe_account.link_expires_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.link_expires_at IS '上述链接的过期时间';


--
-- Name: COLUMN sys_user_stripe_account.can_receive_payments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.can_receive_payments IS '是否可以接收付款';


--
-- Name: COLUMN sys_user_stripe_account.can_make_transfers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.can_make_transfers IS '是否可以进行转账';


--
-- Name: COLUMN sys_user_stripe_account.last_sync_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.last_sync_time IS '最后一次同步 Stripe 状态的时间';


--
-- Name: COLUMN sys_user_stripe_account.is_delete; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sys_user_stripe_account.is_delete IS '逻辑删除标志，true 表示已删除';


--
-- Name: sys_user_stripe_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_user_stripe_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_user_stripe_account_id_seq OWNER TO postgres;

--
-- Name: sys_user_stripe_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_user_stripe_account_id_seq OWNED BY public.sys_user_stripe_account.id;


--
-- Name: chat_message id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message ALTER COLUMN id SET DEFAULT nextval('public.chat_message_id_seq'::regclass);


--
-- Name: rf_balance_detail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_balance_detail ALTER COLUMN id SET DEFAULT nextval('public.rf_balance_detail_id_seq'::regclass);


--
-- Name: rf_bill_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_bill_item ALTER COLUMN id SET DEFAULT nextval('public.rf_bill_item_id_seq'::regclass);


--
-- Name: rf_internal_logistics_task id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_internal_logistics_task ALTER COLUMN id SET DEFAULT nextval('public.rf_internal_logistics_task_id_seq'::regclass);


--
-- Name: rf_product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product ALTER COLUMN id SET DEFAULT nextval('public.rf_product_id_seq'::regclass);


--
-- Name: rf_product_auction_logistics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_auction_logistics ALTER COLUMN id SET DEFAULT nextval('public.rf_product_auction_logistics_id_seq'::regclass);


--
-- Name: rf_product_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_category ALTER COLUMN id SET DEFAULT nextval('public.rf_product_category_id_seq'::regclass);


--
-- Name: rf_product_comment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_comment ALTER COLUMN id SET DEFAULT nextval('public.rf_product_comment_id_seq'::regclass);


--
-- Name: rf_product_non_consignment_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_non_consignment_info ALTER COLUMN id SET DEFAULT nextval('public.rf_product_non_consignment_info_id_seq'::regclass);


--
-- Name: rf_product_return_record id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record ALTER COLUMN id SET DEFAULT nextval('public.rf_product_return_record_id_seq'::regclass);


--
-- Name: rf_product_return_to_seller id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_to_seller ALTER COLUMN id SET DEFAULT nextval('public.rf_product_return_to_seller_id_seq'::regclass);


--
-- Name: rf_product_self_pickup_logistics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_self_pickup_logistics ALTER COLUMN id SET DEFAULT nextval('public.rf_product_self_pickup_logistics_id_seq'::regclass);


--
-- Name: rf_product_sell_record id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record ALTER COLUMN id SET DEFAULT nextval('public.rf_product_sell_record_id_seq'::regclass);


--
-- Name: rf_product_warehouse_shipment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_warehouse_shipment ALTER COLUMN id SET DEFAULT nextval('public.rf_product_warehouse_shipment_id_seq'::regclass);


--
-- Name: rf_purchase_review id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_purchase_review ALTER COLUMN id SET DEFAULT nextval('public.rf_purchase_review_id_seq'::regclass);


--
-- Name: rf_user_address id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_address ALTER COLUMN id SET DEFAULT nextval('public.rf_user_address_id_seq'::regclass);


--
-- Name: rf_user_favorite_product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_favorite_product ALTER COLUMN id SET DEFAULT nextval('public.rf_user_favorite_product_id_seq'::regclass);


--
-- Name: rf_user_product_browse_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_product_browse_history ALTER COLUMN id SET DEFAULT nextval('public.rf_user_product_browse_history_id_seq'::regclass);


--
-- Name: rf_warehouse id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse ALTER COLUMN id SET DEFAULT nextval('public.rf_warehouse_id_seq'::regclass);


--
-- Name: rf_warehouse_cost id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_cost ALTER COLUMN id SET DEFAULT nextval('public.rf_warehouse_cost_id_seq'::regclass);


--
-- Name: rf_warehouse_in id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in ALTER COLUMN id SET DEFAULT nextval('public.rf_warehouse_in_id_seq'::regclass);


--
-- Name: rf_warehouse_in_apply id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in_apply ALTER COLUMN id SET DEFAULT nextval('public.rf_warehouse_in_apply_id_seq'::regclass);


--
-- Name: rf_warehouse_out id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_out ALTER COLUMN id SET DEFAULT nextval('public.rf_warehouse_out_id_seq'::regclass);


--
-- Name: rf_warehouse_stock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock ALTER COLUMN id SET DEFAULT nextval('public.rf_warehouse_stock_id_seq'::regclass);


--
-- Name: sys_menu id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_menu ALTER COLUMN id SET DEFAULT nextval('public.sys_menu_id_seq'::regclass);


--
-- Name: sys_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role ALTER COLUMN id SET DEFAULT nextval('public.sys_role_id_seq'::regclass);


--
-- Name: sys_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user ALTER COLUMN id SET DEFAULT nextval('public.sys_user_id_seq'::regclass);


--
-- Name: sys_user_stripe_account id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_stripe_account ALTER COLUMN id SET DEFAULT nextval('public.sys_user_stripe_account_id_seq'::regclass);


--
-- Data for Name: chat_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.chat_message VALUES (2, 1, 13, 'text', 'hhhh', '2025-06-19 11:48:05.845807', 'sent', '2025-06-19 11:48:05.845828', '2025-06-19 11:48:05.845831', false, true);
INSERT INTO public.chat_message VALUES (3, 1, 13, 'text', '123321', '2025-06-19 11:52:42.062492', 'sent', '2025-06-19 11:52:42.062496', '2025-06-19 11:52:42.062498', false, true);
INSERT INTO public.chat_message VALUES (20, 1, 13, 'text', 'iqiqiq', '2025-06-19 15:32:14.001991', 'sent', '2025-06-19 15:32:14.002', '2025-06-19 15:32:14.002003', false, true);
INSERT INTO public.chat_message VALUES (23, 1, 13, 'text', '在的在的', '2025-06-19 17:03:01.729553', 'sent', '2025-06-19 17:03:01.729564', '2025-06-19 17:03:01.72957', false, true);
INSERT INTO public.chat_message VALUES (4, 13, 1, 'text', '犹犹豫豫', '2025-06-19 14:46:42.293631', 'sent', '2025-06-19 14:46:42.293658', '2025-06-19 14:46:42.293664', false, true);
INSERT INTO public.chat_message VALUES (5, 13, 1, 'text', '哈哈', '2025-06-19 14:53:38.955046', 'sent', '2025-06-19 14:53:38.955064', '2025-06-19 14:53:38.955073', false, true);
INSERT INTO public.chat_message VALUES (6, 13, 1, 'text', '在这个', '2025-06-19 14:55:37.685736', 'sent', '2025-06-19 14:55:37.685749', '2025-06-19 14:55:37.685753', false, true);
INSERT INTO public.chat_message VALUES (7, 13, 1, 'text', 'q', '2025-06-19 15:14:57.001419', 'sent', '2025-06-19 15:14:57.001457', '2025-06-19 15:14:57.001463', false, true);
INSERT INTO public.chat_message VALUES (8, 13, 1, 'text', 'q', '2025-06-19 15:14:58.025377', 'sent', '2025-06-19 15:14:58.025383', '2025-06-19 15:14:58.025386', false, true);
INSERT INTO public.chat_message VALUES (9, 13, 1, 'text', 'q', '2025-06-19 15:14:58.693493', 'sent', '2025-06-19 15:14:58.693501', '2025-06-19 15:14:58.693504', false, true);
INSERT INTO public.chat_message VALUES (10, 13, 1, 'text', 'q', '2025-06-19 15:14:59.279417', 'sent', '2025-06-19 15:14:59.279425', '2025-06-19 15:14:59.279428', false, true);
INSERT INTO public.chat_message VALUES (11, 13, 1, 'text', 's', '2025-06-19 15:14:59.688199', 'sent', '2025-06-19 15:14:59.688206', '2025-06-19 15:14:59.68821', false, true);
INSERT INTO public.chat_message VALUES (12, 13, 1, 'text', 's', '2025-06-19 15:15:00.14259', 'sent', '2025-06-19 15:15:00.142599', '2025-06-19 15:15:00.142602', false, true);
INSERT INTO public.chat_message VALUES (32, 13, 1, 'text', '嘻嘻嘻', '2025-06-21 12:35:20.863176', 'sent', '2025-06-21 12:35:20.863198', '2025-06-21 12:35:20.863202', false, true);
INSERT INTO public.chat_message VALUES (31, 1, 13, 'text', '怎么又是你', '2025-06-19 19:12:45.015178', 'sent', '2025-06-19 19:12:45.015186', '2025-06-19 19:12:45.015188', false, true);
INSERT INTO public.chat_message VALUES (13, 13, 1, 'text', 'q', '2025-06-19 15:15:00.575914', 'sent', '2025-06-19 15:15:00.575923', '2025-06-19 15:15:00.575926', false, true);
INSERT INTO public.chat_message VALUES (14, 13, 1, 'text', 'x', '2025-06-19 15:15:01.01149', 'sent', '2025-06-19 15:15:01.011495', '2025-06-19 15:15:01.011496', false, true);
INSERT INTO public.chat_message VALUES (15, 13, 1, 'text', 'g', '2025-06-19 15:15:01.445539', 'sent', '2025-06-19 15:15:01.445548', '2025-06-19 15:15:01.445551', false, true);
INSERT INTO public.chat_message VALUES (16, 13, 1, 'text', 'rv', '2025-06-19 15:15:02.090422', 'sent', '2025-06-19 15:15:02.09043', '2025-06-19 15:15:02.090434', false, true);
INSERT INTO public.chat_message VALUES (17, 13, 1, 'text', 's', '2025-06-19 15:15:02.648913', 'sent', '2025-06-19 15:15:02.648921', '2025-06-19 15:15:02.648924', false, true);
INSERT INTO public.chat_message VALUES (21, 13, 1, 'text', '什么意思哥们', '2025-06-19 16:05:06.993755', 'sent', '2025-06-19 16:05:06.993775', '2025-06-19 16:05:06.993778', false, true);
INSERT INTO public.chat_message VALUES (22, 13, 1, 'text', '在', '2025-06-19 16:17:17.042332', 'sent', '2025-06-19 16:17:17.042342', '2025-06-19 16:17:17.042356', false, true);
INSERT INTO public.chat_message VALUES (24, 13, 1, 'text', '你要干嘛', '2025-06-19 17:03:39.517298', 'sent', '2025-06-19 17:03:39.517307', '2025-06-19 17:03:39.517309', false, true);
INSERT INTO public.chat_message VALUES (25, 13, 1, 'text', '说话', '2025-06-19 19:00:40.933932', 'sent', '2025-06-19 19:00:40.933942', '2025-06-19 19:00:40.933942', false, true);
INSERT INTO public.chat_message VALUES (26, 13, 1, 'text', 'jjj', '2025-06-19 19:00:47.993251', 'sent', '2025-06-19 19:00:47.993256', '2025-06-19 19:00:47.993257', false, true);
INSERT INTO public.chat_message VALUES (27, 13, 1, 'text', '好', '2025-06-19 19:04:41.382064', 'sent', '2025-06-19 19:04:41.382069', '2025-06-19 19:04:41.382071', false, true);
INSERT INTO public.chat_message VALUES (28, 13, 1, 'text', '好', '2025-06-19 19:06:30.781586', 'sent', '2025-06-19 19:06:30.781591', '2025-06-19 19:06:30.781592', false, true);
INSERT INTO public.chat_message VALUES (29, 13, 1, 'text', 'j', '2025-06-19 19:06:36.783688', 'sent', '2025-06-19 19:06:36.783695', '2025-06-19 19:06:36.783696', false, true);
INSERT INTO public.chat_message VALUES (30, 13, 1, 'text', '喔后悔', '2025-06-19 19:09:09.361464', 'sent', '2025-06-19 19:09:09.361469', '2025-06-19 19:09:09.36147', false, true);


--
-- Data for Name: rf_balance_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_balance_detail VALUES (1, 13, NULL, 2, 'COMMISSION', 12.00, 0.00, 12.00, '确认收货付款 - 订单ID: 14', '2025-06-29 20:08:11.440561', '2025-06-29 20:08:11.440564', '2025-06-29 20:09:51.476801', false);
INSERT INTO public.rf_balance_detail VALUES (2, 13, 1, 3, 'COMMISSION', 545.00, 12.00, 557.00, '确认收货付款 - 订单ID: 15', '2025-06-29 20:09:51.480596', '2025-06-29 20:09:51.480599', '2025-06-30 18:27:22.70356', false);
INSERT INTO public.rf_balance_detail VALUES (3, 13, 2, 4, 'WITHDRAWAL', -200.00, 557.00, 357.00, '提现到Stripe账户', '2025-06-30 18:27:22.708656', '2025-06-30 18:27:22.708665', '2025-06-30 18:40:53.453912', false);
INSERT INTO public.rf_balance_detail VALUES (4, 13, 3, 5, 'WITHDRAWAL', -2.00, 357.00, 355.00, '提现到Stripe账户', '2025-06-30 18:40:53.457419', '2025-06-30 18:40:53.457447', '2025-06-30 18:43:45.337377', false);
INSERT INTO public.rf_balance_detail VALUES (5, 13, 4, 6, 'WITHDRAWAL', -1.00, 355.00, 354.00, '提现到Stripe账户', '2025-06-30 18:43:45.36351', '2025-06-30 18:43:45.363527', '2025-06-30 18:43:53.212406', false);
INSERT INTO public.rf_balance_detail VALUES (6, 13, 5, 7, 'WITHDRAWAL', -3.00, 354.00, 351.00, '提现到Stripe账户', '2025-06-30 18:43:53.215637', '2025-06-30 18:43:53.215641', '2025-06-30 18:44:01.588332', false);
INSERT INTO public.rf_balance_detail VALUES (7, 13, 6, 8, 'WITHDRAWAL', -5.00, 351.00, 346.00, '提现到Stripe账户', '2025-06-30 18:44:01.591287', '2025-06-30 18:44:01.591291', '2025-06-30 18:47:05.602461', false);
INSERT INTO public.rf_balance_detail VALUES (8, 13, 7, 9, 'WITHDRAWAL', -6.00, 346.00, 340.00, '提现到Stripe账户', '2025-06-30 18:47:05.607203', '2025-06-30 18:47:05.607227', '2025-06-30 18:47:16.5572', false);
INSERT INTO public.rf_balance_detail VALUES (9, 13, 8, 10, 'WITHDRAWAL', -2.00, 340.00, 338.00, '提现到Stripe账户', '2025-06-30 18:47:16.56106', '2025-06-30 18:47:16.561066', '2025-06-30 18:47:23.826077', false);
INSERT INTO public.rf_balance_detail VALUES (10, 13, 9, 11, 'WITHDRAWAL', -1.00, 338.00, 337.00, '提现到Stripe账户', '2025-06-30 18:47:23.830498', '2025-06-30 18:47:23.830503', '2025-06-30 18:47:35.400338', false);
INSERT INTO public.rf_balance_detail VALUES (12, 13, 11, NULL, 'WITHDRAWAL', -3.00, 332.00, 329.00, '提现到Stripe账户', '2025-06-30 18:47:49.17498', '2025-06-30 18:47:49.174986', '2025-06-30 18:47:49.174987', false);
INSERT INTO public.rf_balance_detail VALUES (11, 13, 10, 12, 'WITHDRAWAL', -5.00, 337.00, 332.00, '提现到Stripe账户', '2025-06-30 18:47:35.403405', '2025-06-30 18:47:35.403411', '2025-06-30 18:47:49.171957', false);
INSERT INTO public.rf_balance_detail VALUES (13, 1, NULL, 14, 'DEPOSIT', 10.00, 0.00, 10.00, '钱包充值 - 支付ID: pi_3RgQpXQ5plwmdabO10eoAkZE', '2025-07-02 21:36:22.17556', '2025-07-02 21:36:22.175565', '2025-07-02 22:21:04.835594', false);
INSERT INTO public.rf_balance_detail VALUES (14, 1, 13, 15, 'DEPOSIT', 2000.00, 10.00, 2010.00, '钱包充值 - 支付ID: pi_3RgRWqQ5plwmdabO1Fbhyj5U', '2025-07-02 22:21:04.836696', '2025-07-02 22:21:04.836711', '2025-07-02 22:21:39.551355', false);
INSERT INTO public.rf_balance_detail VALUES (15, 1, 14, 16, 'PURCHASE', -1313.00, 2010.00, 697.00, '购买商品: 测试分类页商品 (订单: BAL_1751466099552_1)', '2025-07-02 22:21:39.554191', '2025-07-02 22:21:39.554197', '2025-07-02 22:32:15.75904', false);
INSERT INTO public.rf_balance_detail VALUES (16, 1, 15, 17, 'DEPOSIT', 2000.00, 697.00, 2697.00, '钱包充值 - 支付ID: pi_3RgRheQ5plwmdabO2dLXjONb', '2025-07-02 22:32:15.760089', '2025-07-02 22:32:15.760107', '2025-07-02 22:32:23.923521', false);
INSERT INTO public.rf_balance_detail VALUES (17, 1, 16, 18, 'PURCHASE', -1313.00, 2697.00, 1384.00, '购买商品: 测试非寄卖商品2 (订单: BAL_1751466743924_1)', '2025-07-02 22:32:23.926599', '2025-07-02 22:32:23.92661', '2025-07-02 22:44:40.948113', false);
INSERT INTO public.rf_balance_detail VALUES (19, 1, 18, NULL, 'BILL_PAYMENT', -20.00, 1251.00, 1231.00, '支付账单: 嘻嘻嘻 (账单ID: 2)', '2025-07-03 02:03:25.193792', '2025-07-03 02:03:25.19381', '2025-07-03 02:03:25.193812', false);
INSERT INTO public.rf_balance_detail VALUES (18, 1, 17, 19, 'PURCHASE', -133.00, 1384.00, 1251.00, '购买寄卖商品: 测试寄卖商品q (订单: BAL_1751467480950_1)', '2025-07-02 22:44:40.951732', '2025-07-02 22:44:40.951749', '2025-07-03 02:03:25.187116', false);


--
-- Data for Name: rf_bill_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_bill_item VALUES (1, NULL, NULL, '测试', '嘻嘻休息', 12.00, NULL, false, 13, 'PAID', '2025-06-19 21:17:24.429089', NULL, '2025-06-19 13:01:54.661277', '2025-06-19 21:17:24.429098', false);
INSERT INTO public.rf_bill_item VALUES (2, NULL, NULL, '测试支付账单', '嘻嘻嘻', 20.00, NULL, true, 1, 'PAID', '2025-07-03 02:03:25.262227', NULL, '2025-07-02 17:47:32.54831', '2025-07-03 02:03:25.262233', false);


--
-- Data for Name: rf_internal_logistics_task; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_internal_logistics_task VALUES (13, 23, 7, 'PRODUCT_RETURN', NULL, '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}', NULL, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', NULL, NULL, 'PENDING_ACCEPT', '2025-06-18 17:46:10.249918', '2025-06-18 17:46:10.249923', false, NULL, 8, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (4, 20, NULL, 'PICKUP_SERVICE', 1, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/8eb5b857024e448a81a7487c50fbd895.png","2":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/80ee0fa8cacc4592bf9e285cf970e019.png"}', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/c6d50c1f4bf84d15aa67f2547dca0f0f.png"}', NULL, 'COMPLETED', '2025-06-14 08:33:58.571036', '2025-06-14 08:33:58.571036', false, 17, NULL, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (12, 24, 8, 'PRODUCT_RETURN', 1, '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/c46d0536f7f648ce9fe29dffa24cb57c.png"}', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/f884f39f4d3c4466a650ed32030d497d.png"}', NULL, 'COMPLETED', '2025-06-18 16:14:18.565824', '2025-06-18 16:14:18.565829', false, NULL, 5, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (9, 24, 8, 'WAREHOUSE_SHIPMENT', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/34325052af9442afbdc66cecb520f938.png"}', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/de1d59986bbb4f3b8e90aa4f9b84554d.png"}', 0.00, 'COMPLETED', '2025-06-14 19:05:34.977419', '2025-06-14 19:05:34.977421', false, NULL, NULL, NULL, '+1 12312342134');
INSERT INTO public.rf_internal_logistics_task VALUES (6, 23, NULL, 'PICKUP_SERVICE', 1, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/df7d04cb83844dee9a0bfea96e41795c.png"}', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/ca0a3b9f39bd4caa97271b8a66bbcf5f.png"}', NULL, 'COMPLETED', '2025-06-14 18:14:40.743962', '2025-06-14 18:14:40.743962', false, 19, NULL, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (11, 27, NULL, 'PICKUP_SERVICE', 1, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/196a538be8af41dfb9a2519e0985411b.png"}', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/a4e5a2cf2185440b9d913bad7f1cd286.png"}', NULL, 'COMPLETED', '2025-06-16 12:32:10.818886', '2025-06-16 12:32:10.818886', false, 22, NULL, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (8, 24, NULL, 'PICKUP_SERVICE', 1, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/0c33b70c28244036b646cb488a96023f.png"}', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/fc3d64e19e7c4e5cbac8c4b4e3b83349.png"}', NULL, 'COMPLETED', '2025-06-14 18:59:20.483391', '2025-06-14 18:59:20.483391', false, 20, NULL, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (10, 25, NULL, 'PICKUP_SERVICE', 1, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/caef91916ebd4f44bf4f592f049368bf.png"}', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/962586cd3aad4ca4af3bcf742e0eb9a1.png"}', NULL, 'COMPLETED', '2025-06-16 10:27:22.553399', '2025-06-16 10:27:22.553399', false, 21, NULL, NULL, NULL);
INSERT INTO public.rf_internal_logistics_task VALUES (18, 25, 17, 'WAREHOUSE_SHIPMENT', NULL, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', NULL, '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}', NULL, 0.00, 'PENDING_ACCEPT', '2025-07-02 22:44:41.099507', '2025-07-02 22:44:41.09951', false, NULL, NULL, NULL, '+1 12312342134');
INSERT INTO public.rf_internal_logistics_task VALUES (17, 27, NULL, 'RETURN_TO_SELLER', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/66cf987d20214912a7a567d2f504e7f6.png"}', '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/1ec0eba177c14c9795c11930b2b54555.png"}', NULL, 'COMPLETED', '2025-06-18 21:45:01.527874', '2025-06-18 21:45:01.52794', false, NULL, NULL, 2, NULL);


--
-- Data for Name: rf_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_product VALUES (23, '一瓶水 测试寄卖商品', NULL, 'Others', 31.00, 1, '一瓶水 测试寄卖商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/756af000797d40a0ac31b0522cfc9d13.jpg"}', true, false, '2025-06-14 18:14:39.366594', '2025-06-14 18:55:02.002152', false, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 'Others', 'SOLD', 13, 1, 6);
INSERT INTO public.rf_product VALUES (21, '测试非寄卖商品', NULL, 'Others', 122.00, 1, '测试非寄卖商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/dbd093bcb5ed490bbef30f90ed2b606f.jpg"}', false, true, '2025-06-14 15:53:46.95241', '2025-06-14 16:11:00.76507', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (19, '测试支付商品', NULL, 'Others', 1.00, 1, '测试支付商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/4b20019423c348c4bf6d9b53340afb8c.png"}', false, true, '2025-06-10 16:44:33.795842', '2025-06-11 15:22:27.697863', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (17, '测试非寄卖商品', NULL, 'Others', 13.00, 1, '测试非寄卖商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/21f5a815265f48fe8d008733913e3f1e.jpg"}', false, true, '2025-06-09 16:34:25.949232', '2025-06-11 16:11:32.610692', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (18, '测试非寄卖多图片商品', NULL, 'Others', 555.00, 1, '测试非寄卖多图片商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/4eed7f66f6b64901ba6dcb66967728a3.jpg","2":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/abbaba9d99dc41deba11ec46711fbf41.jpg","3":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/f4940add963548a0aff4a1678d26f83f.jpg"}', false, true, '2025-06-09 17:23:33.436588', '2025-06-13 18:37:44.889854', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (36, 'n s n w ne e', NULL, 'Living Room', 6461.00, 1, 'n s n w ne e', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/219eead9e7ef41bc997c49d1ea1b589b.jpg"}', false, true, '2025-06-19 19:58:49.270881', '2025-06-19 19:58:49.270881', false, '', 'Sofa', 'LISTED', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (28, '测试非寄卖商品', NULL, 'Others', 125.00, 1, '测试非寄卖商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/549555c487bb4888b146d9ab3c3efe48.jpg"}', false, true, '2025-06-18 12:23:54.435395', '2025-06-18 12:24:40.735043', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (34, 'h g g g', NULL, 'Living Room', 12.00, 1, 'h g g g', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/2a966ae97d4442de80021718f6d731a2.jpg"}', false, true, '2025-06-19 19:57:13.652563', '2025-06-29 20:07:58.033046', false, '', 'Sofa', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (26, '测试相机', NULL, 'Others', 133.00, 1, '测试相机', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/adbac99332d34e35ae454fb6f5e21ef4.jpg"}', false, true, '2025-06-16 10:50:54.158632', '2025-06-17 11:29:14.467786', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (29, '测试非寄卖商品1', NULL, 'Others', 13.00, 1, '测试非寄卖商品1', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/7df3bc0623f34d8887baf4d7aefdbe34.jpg"}', false, true, '2025-06-18 16:03:34.46898', '2025-06-18 16:24:01.41778', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (31, '一支水', NULL, 'Others', 32.00, 1, '一支水', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/b1ba91f77baf4b0a817678c74e95ded5.jpg"}', false, true, '2025-06-18 16:33:30.766275', '2025-06-18 16:34:23.301259', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (24, '寄卖1', NULL, 'Others', 123.00, 1, '寄卖1', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/a06c35f0670247f1b120a64795de11f8.jpg"}', true, false, '2025-06-14 18:59:18.382688', '2025-06-18 19:44:52.03884', false, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 'Others', 'LISTED', 13, 1, 7);
INSERT INTO public.rf_product VALUES (35, 'h s g s g s', NULL, 'Living Room', 545.00, 1, 'h s g s g s', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/79444f9ba83d4038ba14b0e9bd7aea4d.jpg"}', false, true, '2025-06-19 19:58:25.330157', '2025-06-29 20:09:45.024941', false, '', 'Sofa', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (27, '测试相机寄卖商品', NULL, 'Others', 3313.00, 1, '测试相机寄卖商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/cb76c81cdc764947bd863d811f9387f3.jpg"}', true, false, '2025-06-16 12:32:10.147409', '2025-06-18 21:45:00.829096', false, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 'Others', 'RETURNED_TO_SELLER', 13, 1, 9);
INSERT INTO public.rf_product VALUES (32, '测试分类页商品', NULL, 'Living Room', 1313.00, 1, '测试分类页商品', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/361d43341d7f48f7b9f29b8eb6f90a90.jpg"}', false, true, '2025-06-19 15:53:51.044168', '2025-06-19 15:53:51.044168', false, '', 'Sofa', 'LISTED', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (33, '测试商品分类2', NULL, 'Living Room', 3355.00, 1, '测试商品分类2', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/5c4d2e7b18c7453fb37bfbf8b7a6685b.jpg"}', false, true, '2025-06-19 19:55:55.656168', '2025-06-19 19:55:55.656168', false, '', 'Sofa', 'LISTED', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (30, '测试非寄卖商品2', NULL, 'Others', 1313.00, 1, '测试非寄卖商品2', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/5401ac87f3914bb08cd3b78f19eb9194.jpg"}', false, true, '2025-06-18 16:05:12.973655', '2025-07-02 22:32:23.923521', false, '', 'Others', 'SOLD', 13, NULL, NULL);
INSERT INTO public.rf_product VALUES (25, '测试寄卖商品q', NULL, 'Others', 133.00, 1, '测试寄卖商品q', '{"1":"https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/04bb77abd8be4322af1a6bb71585b705.jpg"}', true, false, '2025-06-16 10:27:21.55237', '2025-07-02 22:44:40.948113', false, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 'Others', 'SOLD', 13, 1, 8);


--
-- Data for Name: rf_product_auction_logistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_product_auction_logistics VALUES (19, 23, NULL, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', true, '2025-06-15', 6, NULL, NULL, 'WAREHOUSED', '2025-06-14 18:14:39.373988', '2025-06-14 18:14:39.373988', false, 'Morning');
INSERT INTO public.rf_product_auction_logistics VALUES (17, 20, NULL, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', true, '2025-06-14', 4, NULL, NULL, 'WAREHOUSED', '2025-06-14 08:33:56.563653', '2025-06-14 08:33:56.563653', false, 'Morning');
INSERT INTO public.rf_product_auction_logistics VALUES (22, 27, NULL, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', true, '2025-06-16', 11, NULL, NULL, 'WAREHOUSED', '2025-06-16 12:32:10.154341', '2025-06-16 12:32:10.154341', false, 'Afternoon');
INSERT INTO public.rf_product_auction_logistics VALUES (20, 24, NULL, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', true, '2025-06-15', 8, NULL, NULL, 'WAREHOUSED', '2025-06-14 18:59:18.388003', '2025-06-14 18:59:18.388003', false, 'Morning');
INSERT INTO public.rf_product_auction_logistics VALUES (18, 22, NULL, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', true, '2025-06-15', 5, NULL, NULL, 'WAREHOUSED', '2025-06-14 17:58:59.699354', '2025-06-14 17:58:59.699354', false, 'Morning');
INSERT INTO public.rf_product_auction_logistics VALUES (21, 25, NULL, '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', true, '2025-06-16', 10, NULL, NULL, 'WAREHOUSED', '2025-06-16 10:27:21.571388', '2025-06-16 10:27:21.571388', false, 'Afternoon');


--
-- Data for Name: rf_product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_product_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_product_non_consignment_info; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_product_return_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_product_return_record VALUES (3, 28, 10, 'DAMAGED', 'jajja', 'APPROVED', NULL, 'SELLER', NULL, false, NULL, NULL, false, false, NULL, NULL, NULL, NULL, 'RETURNED_TO_SELLER', '2025-06-18 15:55:12.246882', '2025-06-18 15:57:26.268976', false, true, '好的 可以退货', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}');
INSERT INTO public.rf_product_return_record VALUES (4, 30, 11, 'OTHER', '不想要了', 'APPROVED', NULL, 'SELLER', NULL, false, NULL, NULL, false, false, NULL, NULL, NULL, NULL, 'RETURNED_TO_SELLER', '2025-06-18 16:06:39.666102', '2025-06-18 16:07:16.366157', false, true, '牛逼', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}');
INSERT INTO public.rf_product_return_record VALUES (6, 29, 12, 'DAMAGED', '很不想要', 'APPROVED', NULL, 'SELLER', NULL, false, NULL, NULL, false, false, NULL, NULL, NULL, NULL, 'RETURNED_TO_SELLER', '2025-06-18 16:24:24.47663', '2025-06-18 16:32:04.976143', false, true, '滚', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}');
INSERT INTO public.rf_product_return_record VALUES (8, 23, 7, 'OTHER', '不想要', 'APPROVED', '退吧', 'SELLER', 13, false, NULL, NULL, true, false, NULL, 13, NULL, NULL, 'RETURNED_TO_WAREHOUSE', '2025-06-18 17:44:20.919494', '2025-06-18 17:45:07.809035', false, false, '不想退', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}');
INSERT INTO public.rf_product_return_record VALUES (7, 31, 13, 'DAMAGED', 'ruru', 'APPROVED', '111', 'SELLER', 13, false, 'SELLER', 13, false, false, NULL, NULL, NULL, NULL, 'RETURN_COMPLETED', '2025-06-18 16:36:45', '2025-06-18 18:46:01.203883', false, false, '我不退', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}');
INSERT INTO public.rf_product_return_record VALUES (5, 24, 8, 'OTHER', '被喝过了', 'APPROVED', NULL, 'SELLER', NULL, false, NULL, NULL, true, false, NULL, 12, NULL, NULL, 'RETURNED_TO_WAREHOUSE_CONFIRMED', '2025-06-18 16:09:27.136164', '2025-06-18 16:14:18.561213', false, true, '是我喝的', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}');


--
-- Data for Name: rf_product_return_to_seller; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_product_return_to_seller VALUES (2, 27, NULL, 1, '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', 17, NULL, NULL, 'RECEIVED', '2025-06-18 21:45:01.253417', '2025-06-18 21:45:01.25357', false);


--
-- Data for Name: rf_product_self_pickup_logistics; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_product_sell_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_product_sell_record VALUES (3, 19, 13, 13, 1.00, false, NULL, true, NULL, NULL, NULL, 'PENDING_RECEIPT', '2025-06-11 15:22:27.709916', '2025-06-11 15:22:27.709923', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (6, 21, 13, 15, 122.00, false, NULL, true, NULL, NULL, NULL, 'PENDING_RECEIPT', '2025-06-14 16:11:00.814066', '2025-06-14 16:11:00.814074', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (4, 17, 13, 1, 13.00, false, NULL, true, NULL, NULL, NULL, 'CONFIRMED', '2025-06-11 16:11:32.629719', '2025-06-16 20:39:13.606147', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (5, 18, 13, 1, 555.00, false, NULL, true, NULL, '{"1":"/private/var/mobile/Containers/Data/Application/E4259AF3-2AB1-4C11-AFAE-5C4B0DFD2E7F/tmp/image_picker_C0CC8CCD-0FF0-421E-BA2A-FC65DAFDAA03-2758-000000DC5B984E7E.jpg"}', NULL, 'CONFIRMED', '2025-06-13 18:37:44.960878', '2025-06-16 23:56:13.398911', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (9, 26, 13, 1, 133.00, false, NULL, true, NULL, '{"1":"/private/var/mobile/Containers/Data/Application/506AF0B8-1811-4157-9F01-D0C907F69A3B/tmp/image_picker_1BD511EE-4CD8-4554-850E-1A27BC6CEF6B-4750-000001250ADC0BA7.jpg","2":"/private/var/mobile/Containers/Data/Application/506AF0B8-1811-4157-9F01-D0C907F69A3B/tmp/image_picker_02C98EA8-DD52-4F21-A71A-2FF2D8B4972E-4750-000001252048BADD.jpg"}', NULL, 'CONFIRMED', '2025-06-17 11:29:14.513758', '2025-06-17 11:30:55.226774', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (10, 28, 13, 1, 125.00, false, NULL, true, NULL, NULL, NULL, 'RETURNED_TO_SELLER', '2025-06-18 12:24:40.81194', '2025-06-18 15:57:26.263175', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (11, 30, 13, 1, 1313.00, false, NULL, true, NULL, NULL, NULL, 'RETURNED_TO_SELLER', '2025-06-18 16:05:55.477263', '2025-06-18 16:07:16.363816', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (12, 29, 13, 1, 13.00, false, NULL, true, NULL, NULL, NULL, 'RETURNED_TO_SELLER', '2025-06-18 16:24:01.422505', '2025-06-18 16:32:04.969034', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (7, 23, 13, 1, 31.00, true, NULL, false, NULL, NULL, NULL, 'RETURNED_TO_WAREHOUSE', '2025-06-14 18:55:02.051353', '2025-06-18 17:46:10.246127', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (13, 31, 13, 1, 32.00, false, NULL, true, NULL, NULL, NULL, 'RETURN_COMPLETED', '2025-06-18 16:34:23.305544', '2025-06-18 18:46:01.171249', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (8, 24, 13, 1, 123.00, true, NULL, false, NULL, NULL, NULL, 'RETURNED_TO_WAREHOUSE_CONFIRMED', '2025-06-14 19:05:34.973177', '2025-06-18 19:44:52.03884', false, 9);
INSERT INTO public.rf_product_sell_record VALUES (14, 34, 13, 1, 12.00, false, NULL, true, NULL, NULL, NULL, 'CONFIRMED', '2025-06-29 20:07:58.085096', '2025-06-29 20:08:11.435336', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (15, 35, 13, 1, 545.00, false, NULL, true, NULL, NULL, NULL, 'CONFIRMED', '2025-06-29 20:09:45.031755', '2025-06-29 20:09:51.476801', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (16, 30, 13, 1, 1313.00, false, NULL, true, NULL, NULL, NULL, 'PENDING_RECEIPT', '2025-07-02 22:32:23.937725', '2025-07-02 22:32:23.937731', false, NULL);
INSERT INTO public.rf_product_sell_record VALUES (17, 25, 13, 1, 133.00, true, NULL, false, NULL, NULL, NULL, 'PENDING_SHIPMENT', '2025-07-02 22:44:41.091842', '2025-07-02 22:44:41.091855', false, NULL);


--
-- Data for Name: rf_product_warehouse_shipment; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_purchase_review; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_purchase_review VALUES (3, 18, 5, 1, NULL, 'good', '{"1":"/private/var/mobile/Containers/Data/Application/E4259AF3-2AB1-4C11-AFAE-5C4B0DFD2E7F/tmp/image_picker_C0CC8CCD-0FF0-421E-BA2A-FC65DAFDAA03-2758-000000DC5B984E7E.jpg"}', NULL, NULL, '2025-06-16 23:56:14.86079', '2025-06-16 23:56:14.860794', false, 13);
INSERT INTO public.rf_purchase_review VALUES (4, 26, 9, 1, NULL, 'higihihi', '{"1":"/private/var/mobile/Containers/Data/Application/506AF0B8-1811-4157-9F01-D0C907F69A3B/tmp/image_picker_1BD511EE-4CD8-4554-850E-1A27BC6CEF6B-4750-000001250ADC0BA7.jpg","2":"/private/var/mobile/Containers/Data/Application/506AF0B8-1811-4157-9F01-D0C907F69A3B/tmp/image_picker_02C98EA8-DD52-4F21-A71A-2FF2D8B4972E-4750-000001252048BADD.jpg"}', NULL, NULL, '2025-06-17 11:30:56.615902', '2025-06-17 11:30:56.615905', false, 13);
INSERT INTO public.rf_purchase_review VALUES (5, 34, 14, 1, NULL, 'good', NULL, NULL, NULL, '2025-06-29 20:08:11.450308', '2025-06-29 20:08:11.450311', false, 13);
INSERT INTO public.rf_purchase_review VALUES (6, 35, 15, 1, NULL, 'good', NULL, NULL, NULL, '2025-06-29 20:09:51.488496', '2025-06-29 20:09:51.488498', false, 13);


--
-- Data for Name: rf_user_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_user_address VALUES (4, 13, 'test2', '+1 1231333111', '{"latitude":37.770231227984155,"longitude":-122.41060617607945,"formattedAddress":"450 10th St, San Francisco, CA 94103美国","placeId":"ChIJgw2Zzih-j4ARbBBlXwrvToc"}', false, '2025-06-05 21:34:04.874697', '2025-06-05 21:34:04.874712', false);
INSERT INTO public.rf_user_address VALUES (2, 13, 'test', '+1 1231231237', '{"latitude":37.770231227984155,"longitude":-122.41060617607945,"formattedAddress":"450 10th St, San Francisco, CA 94103美国","placeId":"ChIJgw2Zzih-j4ARbBBlXwrvToc"}', true, '2025-06-04 14:05:24.493803', '2025-06-04 14:05:24.493825', true);
INSERT INTO public.rf_user_address VALUES (5, 13, 'test4', '+1 1231131313', '{
  "latitude":37.770231227984155,
  "longitude":-122.41060617607945,
  "formattedAddress":"450 10th St, San Francisco, CA 94103美国",
  "placeId":"ChIJgw2Zzih-j4ARbBBlXwrvToc"
}', false, '2025-06-05 21:34:19.05138', '2025-06-09 13:32:51.74084', false);
INSERT INTO public.rf_user_address VALUES (6, 13, 'TEST-00', '+1 1231231234', '{
  "latitude":37.66481132552085,
  "longitude":-122.44781199842691,
  "formattedAddress":"1600 El Camino Real, 南三藩市, CA, 美国",
  "placeId":""
}', true, '2025-06-06 21:42:00.524351', '2025-06-06 21:42:00.524361', true);
INSERT INTO public.rf_user_address VALUES (7, 13, 'Chen Chen', '+1 1231231234', '{
  "latitude":37.79879676471874,
  "longitude":-122.23840355873108,
  "formattedAddress":"2519 11th Ave, 奥克兰, CA, 美国",
  "placeId":""
}', false, '2025-06-06 21:59:11.972198', '2025-06-07 12:12:01.050509', false);
INSERT INTO public.rf_user_address VALUES (1, 13, 'chenchen', '+1 1231234123', '{
  "latitude":37.76665338218137,
  "longitude":-122.39752728492022,
  "formattedAddress":"1050 16th St, 旧金山, CA, 美国",
  "placeId":""
}', false, '2025-06-04 13:51:24.960614', '2025-06-14 08:33:33.438089', false);
INSERT INTO public.rf_user_address VALUES (3, 13, 'test1', '+1 1231231231', '{
  "latitude":23.013309635748644,
  "longitude":113.15571997314692,
  "formattedAddress":"季华七路83号, 佛山市, 广东省, 中国",
  "placeId":""
}', true, '2025-06-05 21:33:53.275979', '2025-06-14 08:33:49.36146', false);
INSERT INTO public.rf_user_address VALUES (9, 1, 'test address', '+1 1556549123', '{
  "latitude":23.052982667591966,
  "longitude":113.13742194324732,
  "formattedAddress":"海四路与罗颖尧路交叉口北180米, 佛山市, 广东省, 中国",
  "placeId":""
}', false, '2025-06-14 15:08:58.09626', '2025-06-14 15:08:58.096276', false);
INSERT INTO public.rf_user_address VALUES (10, 15, 'test', '+1 1234567890', '{
  "latitude":23.036238604598424,
  "longitude":113.19487117230892,
  "formattedAddress":"南港路辅路, 佛山市, 广东省, 中国",
  "placeId":""
}', true, '2025-06-14 16:03:28.756937', '2025-06-14 16:03:28.756954', false);
INSERT INTO public.rf_user_address VALUES (8, 1, 'chenchen', '+1 12312342134', '{
  "latitude":23.09861718523023,
  "longitude":113.34026969969273,
  "formattedAddress":"新港东路, 广州市, 广东省, 中国",
  "placeId":""
}', true, '2025-06-11 15:56:59.309948', '2025-06-14 19:05:18.533627', false);


--
-- Data for Name: rf_user_favorite_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_user_favorite_product VALUES (7, 1, 36, '2025-07-07 05:05:39.882456');
INSERT INTO public.rf_user_favorite_product VALUES (8, 1, 32, '2025-07-07 05:24:29.230526');


--
-- Data for Name: rf_user_product_browse_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_user_product_browse_history VALUES (1, 1, 32, '2025-07-08 02:44:03.841531', false, '2025-07-08 02:43:25.920967', '2025-07-08 02:44:03.840044');
INSERT INTO public.rf_user_product_browse_history VALUES (3, 1, 24, '2025-07-08 02:49:50.638971', false, '2025-07-08 02:44:37.909579', '2025-07-08 02:49:50.638623');
INSERT INTO public.rf_user_product_browse_history VALUES (2, 1, 36, '2025-07-08 02:50:25.027518', false, '2025-07-08 02:43:48.297992', '2025-07-08 02:50:25.025987');
INSERT INTO public.rf_user_product_browse_history VALUES (4, 1, 33, '2025-07-08 03:10:27.917021', false, '2025-07-08 03:10:21.003402', '2025-07-08 03:10:27.916077');


--
-- Data for Name: rf_warehouse; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_warehouse VALUES (3, '测试仓库地址', '{"latitude":23.049723304206015,"longitude":113.14750671386719,"formattedAddress":"中国佛山市南海区千灯湖 邮政编码: 528253","placeId":"ChIJbVgpep9ZAjQRHnAQHxuzb0Y"}', 0.00, 'ENABLED', '2025-06-06 02:36:35.046461', '2025-06-09 13:25:29.456691', true);
INSERT INTO public.rf_warehouse VALUES (1, '测试仓库-石啃', '{"latitude":23.007219207021162,"longitude":113.15631002970281,"formattedAddress":"中国广东省佛山市南海区清风路7号 邮政编码: 528200","placeId":"ChIJbedj1jlaAjQRNLE9ESoIcqw"}', 0.01, 'ENABLED', '2025-06-06 00:17:40.702194', '2025-06-09 13:28:14.256437', false);
INSERT INTO public.rf_warehouse VALUES (4, '测试仓库-千灯湖', '{"latitude":23.04916489689117,"longitude":113.14834485778337,"formattedAddress":"中国广东省佛山市南海区南八路 邮政编码: 528253","placeId":"ChIJN2whZp9ZAjQRnWf_TMVdk0Q"}', 0.00, 'ENABLED', '2025-06-09 13:27:54.321321', '2025-06-09 13:28:19.801027', false);
INSERT INTO public.rf_warehouse VALUES (5, '测试仓库-祖庙', '{"latitude":23.032069552905416,"longitude":113.11238580420975,"formattedAddress":"中国广东省佛山市禅城区祖庙路13号 邮政编码: 528011","placeId":"ChIJc05KaeJbAjQRrNNLVzzB9ks"}', 0.00, 'ENABLED', '2025-06-09 13:29:19.532887', '2025-06-09 13:29:19.532887', false);


--
-- Data for Name: rf_warehouse_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_warehouse_in; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_warehouse_in_apply; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_warehouse_out; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rf_warehouse_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rf_warehouse_stock VALUES (6, 1, 23, 1, NULL, NULL, NULL, '2025-06-14 18:15:31.552891', NULL, '2025-06-14 18:55:02.007108', 'OUT_OF_STOCK', '2025-06-14 18:15:31.539637', '2025-06-14 18:15:31.539637', false, 'PICKUP_SERVICE', 'SOLD');
INSERT INTO public.rf_warehouse_stock VALUES (7, 1, 24, 1, NULL, NULL, NULL, '2025-06-14 19:04:33.246923', NULL, '2025-06-14 19:05:34.970311', 'OUT_OF_STOCK', '2025-06-14 19:04:33.225159', '2025-06-14 19:04:33.225159', false, 'PICKUP_SERVICE', 'SOLD');
INSERT INTO public.rf_warehouse_stock VALUES (9, 1, 27, 1, NULL, NULL, NULL, '2025-06-17 11:35:47.041806', NULL, NULL, 'IN_STOCK', '2025-06-17 11:35:47.031292', '2025-06-17 11:35:47.031292', false, 'PICKUP_SERVICE', NULL);
INSERT INTO public.rf_warehouse_stock VALUES (8, 1, 25, 1, NULL, NULL, NULL, '2025-06-16 10:27:59.839038', NULL, '2025-07-02 22:44:41.086364', 'OUT_OF_STOCK', '2025-06-16 10:27:59.829057', '2025-06-16 10:27:59.829057', false, 'PICKUP_SERVICE', 'SOLD');


--
-- Data for Name: sys_menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_menu VALUES (2, '测试菜单1', 0, 0, '', '', '', '', 1, 0, 'C', '0', '0', 'test1', '', '', NULL, '', NULL, '');
INSERT INTO public.sys_menu VALUES (3, '测试菜单2', 0, 0, '', '', '', '', 1, 0, 'C', '0', '0', 'test2', '', '', NULL, '', NULL, '');


--
-- Data for Name: sys_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_role VALUES (1, 'Administrator', '超级管理员');
INSERT INTO public.sys_role VALUES (2, 'user', '一般用户');
INSERT INTO public.sys_role VALUES (3, 'visitor', '游客');


--
-- Data for Name: sys_role_menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_role_menu VALUES (2, 2);
INSERT INTO public.sys_role_menu VALUES (2, 3);


--
-- Data for Name: sys_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_user VALUES (15, 'test', '$2a$10$fpHlSg11h2yxu/nw1vEaPuOV0phZoNTGaVNupYoE4ATQ1WR5r5OEa', 2, NULL, 'https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/1e8b9e072ee04d148278b429a669d061.png', 'TEST', 'test@mc.com', '18018091809', 'M', NULL, '2025-06-14 15:59:03.097921', NULL, '2025-06-14 15:58:41.022291', NULL, NULL, false, '用户', NULL, NULL, NULL, NULL);
INSERT INTO public.sys_user VALUES (1, 'root', '$2a$10$5auJrSy2H7esy2RMVJJnS.k8CULQfPO.mQKOrM.SPK6AbXTgna2y2', 1, NULL, 'https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/images/c3af1d6383da4c8c940300199dadc44b.jpg', '超级管理员', 'root@charno.com', '1234567891', '', NULL, '2025-07-08 02:42:50.28912', NULL, '2025-05-25 17:14:22.879157', NULL, '2025-06-14 09:08:05.168351', false, '用户', NULL, NULL, NULL, NULL);
INSERT INTO public.sys_user VALUES (13, 'aa928531940', NULL, 1, NULL, 'https://reflip-bucket.s3.ap-east-1.amazonaws.com/reflip-uploads/avatars/google/aa928531940_d0749e6b.jpg', 'Setal Im', 'aa928531940@gmail.com', NULL, 'unset', NULL, '2025-07-01 22:13:16.390598', NULL, '2025-05-29 20:18:38.970985', NULL, NULL, false, '用户', '101970289010335667447', NULL, NULL, NULL);


--
-- Data for Name: sys_user_stripe_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_user_stripe_account VALUES (1, 13, 'acct_1RaYAJPt4HSkcjdo', '2025-06-16 16:13:17.456863', '2025-07-01 22:27:57.69749', 'active', 'verified', '{"acssDebitPayments":null,"affirmPayments":null,"afterpayClearpayPayments":null,"auBecsDebitPayments":null,"bacsDebitPayments":null,"bancontactPayments":null,"bankTransferPayments":null,"blikPayments":null,"boletoPayments":null,"cardIssuing":null,"cardPayments":null,"cartesBancairesPayments":null,"cashappPayments":null,"epsPayments":null,"fpxPayments":null,"giropayPayments":null,"grabpayPayments":null,"idealPayments":null,"indiaInternationalPayments":null,"jcbPayments":null,"klarnaPayments":null,"konbiniPayments":null,"legacyPayments":null,"linkPayments":null,"oxxoPayments":null,"p24Payments":null,"paynowPayments":null,"promptpayPayments":null,"revolutPayPayments":null,"sepaDebitPayments":null,"sofortPayments":null,"swishPayments":null,"taxReportingUs1099K":null,"taxReportingUs1099Misc":null,"transfers":"active","treasury":null,"usBankAccountAchPayments":null,"zipPayments":null,"lastResponse":null,"rawJsonObject":null}', '{"alternatives":[],"currentDeadline":null,"currentlyDue":[],"disabledReason":null,"errors":[],"eventuallyDue":[],"pastDue":[],"pendingVerification":[],"lastResponse":null,"rawJsonObject":null}', 'https://connect.stripe.com/setup/e/acct_1RaYAJPt4HSkcjdo/pyuCjb3G0nqA', '2025-06-26 19:45:16.644722', true, true, '2025-07-01 22:27:57.697481', false);
INSERT INTO public.sys_user_stripe_account VALUES (2, 1, 'acct_1RaYKSQ1Is2g6zoh', '2025-06-16 16:23:46.131422', '2025-07-08 03:10:45.928198', 'pending', 'pending', '{"acssDebitPayments":null,"affirmPayments":"inactive","afterpayClearpayPayments":"inactive","auBecsDebitPayments":null,"bacsDebitPayments":null,"bancontactPayments":"inactive","bankTransferPayments":null,"blikPayments":null,"boletoPayments":null,"cardIssuing":null,"cardPayments":"inactive","cartesBancairesPayments":null,"cashappPayments":"inactive","epsPayments":"inactive","fpxPayments":null,"giropayPayments":"inactive","grabpayPayments":null,"idealPayments":"inactive","indiaInternationalPayments":null,"jcbPayments":null,"klarnaPayments":null,"konbiniPayments":null,"legacyPayments":null,"linkPayments":"inactive","oxxoPayments":null,"p24Payments":"inactive","paynowPayments":null,"promptpayPayments":null,"revolutPayPayments":null,"sepaDebitPayments":"inactive","sofortPayments":"inactive","swishPayments":null,"taxReportingUs1099K":null,"taxReportingUs1099Misc":null,"transfers":"inactive","treasury":null,"usBankAccountAchPayments":"inactive","zipPayments":null,"lastResponse":null,"rawJsonObject":null}', '{"alternatives":[{"alternativeFieldsDue":["business_profile.product_description"],"originalFieldsDue":["business_profile.url"],"lastResponse":null,"rawJsonObject":null},{"alternativeFieldsDue":["individual.verification.document"],"originalFieldsDue":["individual.id_number"],"lastResponse":null,"rawJsonObject":null}],"currentDeadline":null,"currentlyDue":["business_profile.mcc","business_profile.url","external_account","individual.verification.document","tos_acceptance.date","tos_acceptance.ip"],"disabledReason":"requirements.past_due","errors":[{"code":"verification_failed_keyed_identity","reason":"The person''s keyed-in identity information could not be verified. Correct any errors or upload a document that matches the identity fields (e.g., name and date of birth) entered.","requirement":"individual.verification.document","lastResponse":null,"rawJsonObject":null}],"eventuallyDue":["business_profile.mcc","business_profile.url","external_account","individual.id_number","individual.verification.document","tos_acceptance.date","tos_acceptance.ip"],"pastDue":["business_profile.mcc","business_profile.url","external_account","individual.verification.document","tos_acceptance.date","tos_acceptance.ip"],"pendingVerification":[],"lastResponse":null,"rawJsonObject":null}', 'https://connect.stripe.com/setup/e/acct_1RaYKSQ1Is2g6zoh/a5PXzwhJIAAX', '2025-06-25 20:53:21.32588', false, false, '2025-07-08 03:10:45.928193', false);


--
-- Name: chat_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_message_id_seq', 32, true);


--
-- Name: rf_balance_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_balance_detail_id_seq', 19, true);


--
-- Name: rf_bill_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_bill_item_id_seq', 2, true);


--
-- Name: rf_internal_logistics_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_internal_logistics_task_id_seq', 18, true);


--
-- Name: rf_product_auction_logistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_auction_logistics_id_seq', 22, true);


--
-- Name: rf_product_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_category_id_seq', 1, false);


--
-- Name: rf_product_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_comment_id_seq', 1, false);


--
-- Name: rf_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_id_seq', 36, true);


--
-- Name: rf_product_non_consignment_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_non_consignment_info_id_seq', 1, false);


--
-- Name: rf_product_return_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_return_record_id_seq', 8, true);


--
-- Name: rf_product_return_to_seller_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_return_to_seller_id_seq', 2, true);


--
-- Name: rf_product_self_pickup_logistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_self_pickup_logistics_id_seq', 1, false);


--
-- Name: rf_product_sell_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_sell_record_id_seq', 17, true);


--
-- Name: rf_product_warehouse_shipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_product_warehouse_shipment_id_seq', 1, false);


--
-- Name: rf_purchase_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_purchase_review_id_seq', 6, true);


--
-- Name: rf_user_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_user_address_id_seq', 10, true);


--
-- Name: rf_user_favorite_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_user_favorite_product_id_seq', 8, true);


--
-- Name: rf_user_product_browse_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_user_product_browse_history_id_seq', 4, true);


--
-- Name: rf_warehouse_cost_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_warehouse_cost_id_seq', 1, false);


--
-- Name: rf_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_warehouse_id_seq', 5, true);


--
-- Name: rf_warehouse_in_apply_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_warehouse_in_apply_id_seq', 1, false);


--
-- Name: rf_warehouse_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_warehouse_in_id_seq', 1, false);


--
-- Name: rf_warehouse_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_warehouse_out_id_seq', 1, false);


--
-- Name: rf_warehouse_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rf_warehouse_stock_id_seq', 9, true);


--
-- Name: sys_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_menu_id_seq', 3, true);


--
-- Name: sys_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_role_id_seq', 3, true);


--
-- Name: sys_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_user_id_seq', 15, true);


--
-- Name: sys_user_stripe_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_user_stripe_account_id_seq', 2, true);


--
-- Name: chat_message chat_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_pkey PRIMARY KEY (id);


--
-- Name: rf_balance_detail rf_balance_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_balance_detail
    ADD CONSTRAINT rf_balance_detail_pkey PRIMARY KEY (id);


--
-- Name: rf_bill_item rf_bill_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_bill_item
    ADD CONSTRAINT rf_bill_item_pkey PRIMARY KEY (id);


--
-- Name: rf_internal_logistics_task rf_internal_logistics_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_internal_logistics_task
    ADD CONSTRAINT rf_internal_logistics_task_pkey PRIMARY KEY (id);


--
-- Name: rf_product_auction_logistics rf_product_auction_logistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_auction_logistics
    ADD CONSTRAINT rf_product_auction_logistics_pkey PRIMARY KEY (id);


--
-- Name: rf_product_category rf_product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_category
    ADD CONSTRAINT rf_product_category_pkey PRIMARY KEY (id);


--
-- Name: rf_product_comment rf_product_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_comment
    ADD CONSTRAINT rf_product_comment_pkey PRIMARY KEY (id);


--
-- Name: rf_product_non_consignment_info rf_product_non_consignment_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_non_consignment_info
    ADD CONSTRAINT rf_product_non_consignment_info_pkey PRIMARY KEY (id);


--
-- Name: rf_product rf_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product
    ADD CONSTRAINT rf_product_pkey PRIMARY KEY (id);


--
-- Name: rf_product_return_record rf_product_return_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record
    ADD CONSTRAINT rf_product_return_record_pkey PRIMARY KEY (id);


--
-- Name: rf_product_return_to_seller rf_product_return_to_seller_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_to_seller
    ADD CONSTRAINT rf_product_return_to_seller_pkey PRIMARY KEY (id);


--
-- Name: rf_product_self_pickup_logistics rf_product_self_pickup_logistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_self_pickup_logistics
    ADD CONSTRAINT rf_product_self_pickup_logistics_pkey PRIMARY KEY (id);


--
-- Name: rf_product_sell_record rf_product_sell_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record
    ADD CONSTRAINT rf_product_sell_record_pkey PRIMARY KEY (id);


--
-- Name: rf_product_warehouse_shipment rf_product_warehouse_shipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_warehouse_shipment
    ADD CONSTRAINT rf_product_warehouse_shipment_pkey PRIMARY KEY (id);


--
-- Name: rf_purchase_review rf_purchase_review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_purchase_review
    ADD CONSTRAINT rf_purchase_review_pkey PRIMARY KEY (id);


--
-- Name: rf_user_address rf_user_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_address
    ADD CONSTRAINT rf_user_address_pkey PRIMARY KEY (id);


--
-- Name: rf_user_favorite_product rf_user_favorite_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_favorite_product
    ADD CONSTRAINT rf_user_favorite_product_pkey PRIMARY KEY (id);


--
-- Name: rf_user_product_browse_history rf_user_product_browse_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_product_browse_history
    ADD CONSTRAINT rf_user_product_browse_history_pkey PRIMARY KEY (id);


--
-- Name: rf_warehouse_cost rf_warehouse_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_cost
    ADD CONSTRAINT rf_warehouse_cost_pkey PRIMARY KEY (id);


--
-- Name: rf_warehouse_in_apply rf_warehouse_in_apply_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in_apply
    ADD CONSTRAINT rf_warehouse_in_apply_pkey PRIMARY KEY (id);


--
-- Name: rf_warehouse_in rf_warehouse_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in
    ADD CONSTRAINT rf_warehouse_in_pkey PRIMARY KEY (id);


--
-- Name: rf_warehouse_out rf_warehouse_out_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_out
    ADD CONSTRAINT rf_warehouse_out_pkey PRIMARY KEY (id);


--
-- Name: rf_warehouse rf_warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse
    ADD CONSTRAINT rf_warehouse_pkey PRIMARY KEY (id);


--
-- Name: rf_warehouse_stock rf_warehouse_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock
    ADD CONSTRAINT rf_warehouse_stock_pkey PRIMARY KEY (id);


--
-- Name: sys_menu sys_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_menu
    ADD CONSTRAINT sys_menu_pkey PRIMARY KEY (id);


--
-- Name: sys_role sys_role_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role
    ADD CONSTRAINT sys_role_key_key UNIQUE (key);


--
-- Name: sys_role_menu sys_role_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role_menu
    ADD CONSTRAINT sys_role_menu_pkey PRIMARY KEY (role_id, menu_id);


--
-- Name: sys_role sys_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role
    ADD CONSTRAINT sys_role_name_key UNIQUE (name);


--
-- Name: sys_role sys_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role
    ADD CONSTRAINT sys_role_pkey PRIMARY KEY (id);


--
-- Name: sys_user sys_user_apple_sub_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_apple_sub_key UNIQUE (apple_sub);


--
-- Name: sys_user sys_user_email_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_email_pk UNIQUE (email);


--
-- Name: sys_user sys_user_google_sub_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_google_sub_key UNIQUE (google_sub);


--
-- Name: sys_user sys_user_phone_number_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_phone_number_pk UNIQUE (phone_number);


--
-- Name: sys_user sys_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_pkey PRIMARY KEY (id);


--
-- Name: sys_user_stripe_account sys_user_stripe_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_stripe_account
    ADD CONSTRAINT sys_user_stripe_account_pkey PRIMARY KEY (id);


--
-- Name: sys_user_stripe_account sys_user_stripe_account_stripe_account_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_stripe_account
    ADD CONSTRAINT sys_user_stripe_account_stripe_account_id_key UNIQUE (stripe_account_id);


--
-- Name: sys_user_stripe_account sys_user_stripe_account_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_stripe_account
    ADD CONSTRAINT sys_user_stripe_account_user_id_key UNIQUE (user_id);


--
-- Name: sys_user sys_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_username_key UNIQUE (username);


--
-- Name: sys_user sys_user_wechat_open_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_wechat_open_id_pk UNIQUE (wechat_open_id);


--
-- Name: rf_product_category uk_product_category_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_category
    ADD CONSTRAINT uk_product_category_name UNIQUE (name);


--
-- Name: rf_user_favorite_product uk_user_product_favorite; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_favorite_product
    ADD CONSTRAINT uk_user_product_favorite UNIQUE (user_id, product_id);


--
-- Name: idx_browse_history_browse_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_browse_history_browse_time ON public.rf_user_product_browse_history USING btree (browse_time DESC);


--
-- Name: idx_browse_history_is_delete; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_browse_history_is_delete ON public.rf_user_product_browse_history USING btree (is_delete);


--
-- Name: idx_browse_history_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_browse_history_product_id ON public.rf_user_product_browse_history USING btree (product_id);


--
-- Name: idx_browse_history_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_browse_history_user_id ON public.rf_user_product_browse_history USING btree (user_id);


--
-- Name: idx_browse_history_user_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_browse_history_user_product ON public.rf_user_product_browse_history USING btree (user_id, product_id);


--
-- Name: idx_browse_history_user_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_browse_history_user_time ON public.rf_user_product_browse_history USING btree (user_id, browse_time DESC);


--
-- Name: idx_chat_message_send_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_message_send_time ON public.chat_message USING btree (send_time);


--
-- Name: idx_chat_message_sender_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_message_sender_receiver ON public.chat_message USING btree (sender_user_id, receiver_user_id);


--
-- Name: idx_product_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_category_id ON public.rf_product USING btree (category_id);


--
-- Name: idx_product_is_delete; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_is_delete ON public.rf_product USING btree (is_delete);


--
-- Name: idx_rf_balance_detail_next; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_balance_detail_next ON public.rf_balance_detail USING btree (next_detail_id);


--
-- Name: idx_rf_balance_detail_prev; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_balance_detail_prev ON public.rf_balance_detail USING btree (prev_detail_id);


--
-- Name: idx_rf_balance_detail_transaction_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_balance_detail_transaction_time ON public.rf_balance_detail USING btree (transaction_time);


--
-- Name: idx_rf_balance_detail_transaction_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_balance_detail_transaction_type ON public.rf_balance_detail USING btree (transaction_type);


--
-- Name: idx_rf_balance_detail_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_balance_detail_user_id ON public.rf_balance_detail USING btree (user_id);


--
-- Name: idx_rf_balance_detail_user_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_balance_detail_user_time ON public.rf_balance_detail USING btree (user_id, transaction_time);


--
-- Name: idx_rf_user_address_is_default; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_user_address_is_default ON public.rf_user_address USING btree (is_default);


--
-- Name: idx_rf_user_address_is_delete; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_user_address_is_delete ON public.rf_user_address USING btree (is_delete);


--
-- Name: idx_rf_user_address_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_user_address_user_id ON public.rf_user_address USING btree (user_id);


--
-- Name: idx_rf_user_favorite_product_favorite_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_user_favorite_product_favorite_time ON public.rf_user_favorite_product USING btree (favorite_time);


--
-- Name: idx_rf_user_favorite_product_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_user_favorite_product_product_id ON public.rf_user_favorite_product USING btree (product_id);


--
-- Name: idx_rf_user_favorite_product_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rf_user_favorite_product_user_id ON public.rf_user_favorite_product USING btree (user_id);


--
-- Name: idx_sell_record_buyer_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sell_record_buyer_user_id ON public.rf_product_sell_record USING btree (buyer_user_id);


--
-- Name: idx_sell_record_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sell_record_product_id ON public.rf_product_sell_record USING btree (product_id);


--
-- Name: idx_sell_record_seller_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sell_record_seller_user_id ON public.rf_product_sell_record USING btree (seller_user_id);


--
-- Name: idx_sell_record_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sell_record_status ON public.rf_product_sell_record USING btree (status);


--
-- Name: idx_warehouse_stock_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_stock_product_id ON public.rf_warehouse_stock USING btree (product_id);


--
-- Name: idx_warehouse_stock_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_warehouse_stock_warehouse_id ON public.rf_warehouse_stock USING btree (warehouse_id);


--
-- Name: rf_balance_detail trigger_rf_balance_detail_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_rf_balance_detail_updated_at BEFORE UPDATE ON public.rf_balance_detail FOR EACH ROW EXECUTE FUNCTION public.update_rf_balance_detail_updated_at();


--
-- Name: rf_user_product_browse_history trigger_update_browse_history_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_browse_history_updated_at BEFORE UPDATE ON public.rf_user_product_browse_history FOR EACH ROW EXECUTE FUNCTION public.update_browse_history_updated_at();


--
-- Name: rf_product_category update_rf_product_category_updated_time; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_rf_product_category_updated_time BEFORE UPDATE ON public.rf_product_category FOR EACH ROW EXECUTE FUNCTION public.update_updated_time_column();


--
-- Name: rf_product_sell_record update_rf_product_sell_record_updated_time; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_rf_product_sell_record_updated_time BEFORE UPDATE ON public.rf_product_sell_record FOR EACH ROW EXECUTE FUNCTION public.update_updated_time_column();


--
-- Name: rf_product update_rf_product_updated_time; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_rf_product_updated_time BEFORE UPDATE ON public.rf_product FOR EACH ROW EXECUTE FUNCTION public.update_updated_time_column();


--
-- Name: rf_warehouse update_rf_warehouse_updated_time; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_rf_warehouse_updated_time BEFORE UPDATE ON public.rf_warehouse FOR EACH ROW EXECUTE FUNCTION public.update_updated_time_column();


--
-- Name: rf_user_product_browse_history fk_browse_history_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_product_browse_history
    ADD CONSTRAINT fk_browse_history_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_user_product_browse_history fk_browse_history_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_user_product_browse_history
    ADD CONSTRAINT fk_browse_history_user FOREIGN KEY (user_id) REFERENCES public.sys_user(id);


--
-- Name: chat_message fk_chat_message_receiver; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT fk_chat_message_receiver FOREIGN KEY (receiver_user_id) REFERENCES public.sys_user(id);


--
-- Name: chat_message fk_chat_message_sender; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT fk_chat_message_sender FOREIGN KEY (sender_user_id) REFERENCES public.sys_user(id);


--
-- Name: rf_product_return_record fk_return_record_compensation_bearer_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record
    ADD CONSTRAINT fk_return_record_compensation_bearer_user FOREIGN KEY (compensation_bearer_user_id) REFERENCES public.sys_user(id);


--
-- Name: rf_product_return_record fk_return_record_freight_bearer_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record
    ADD CONSTRAINT fk_return_record_freight_bearer_user FOREIGN KEY (freight_bearer_user_id) REFERENCES public.sys_user(id);


--
-- Name: rf_product_return_record fk_return_record_internal_logistics; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record
    ADD CONSTRAINT fk_return_record_internal_logistics FOREIGN KEY (internal_logistics_task_id) REFERENCES public.rf_internal_logistics_task(id);


--
-- Name: rf_product_return_record fk_return_record_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record
    ADD CONSTRAINT fk_return_record_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_product_return_record fk_return_record_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_return_record
    ADD CONSTRAINT fk_return_record_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_product_self_pickup_logistics fk_self_pickup_logistics_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_self_pickup_logistics
    ADD CONSTRAINT fk_self_pickup_logistics_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_product_self_pickup_logistics fk_self_pickup_logistics_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_self_pickup_logistics
    ADD CONSTRAINT fk_self_pickup_logistics_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_product_sell_record fk_sell_record_buyer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record
    ADD CONSTRAINT fk_sell_record_buyer FOREIGN KEY (buyer_user_id) REFERENCES public.sys_user(id);


--
-- Name: rf_product_sell_record fk_sell_record_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record
    ADD CONSTRAINT fk_sell_record_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_product_sell_record fk_sell_record_self_pickup_logistics; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record
    ADD CONSTRAINT fk_sell_record_self_pickup_logistics FOREIGN KEY (product_self_pickup_logistics_id) REFERENCES public.rf_product_self_pickup_logistics(id);


--
-- Name: rf_product_sell_record fk_sell_record_seller; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record
    ADD CONSTRAINT fk_sell_record_seller FOREIGN KEY (seller_user_id) REFERENCES public.sys_user(id);


--
-- Name: rf_product_sell_record fk_sell_record_warehouse_shipment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_sell_record
    ADD CONSTRAINT fk_sell_record_warehouse_shipment FOREIGN KEY (product_warehouse_shipment_id) REFERENCES public.rf_product_warehouse_shipment(id);


--
-- Name: rf_warehouse_cost fk_warehouse_cost_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_cost
    ADD CONSTRAINT fk_warehouse_cost_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_warehouse_cost fk_warehouse_cost_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_cost
    ADD CONSTRAINT fk_warehouse_cost_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_warehouse_cost fk_warehouse_cost_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_cost
    ADD CONSTRAINT fk_warehouse_cost_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.rf_warehouse(id);


--
-- Name: rf_warehouse_in_apply fk_warehouse_in_apply_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in_apply
    ADD CONSTRAINT fk_warehouse_in_apply_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_warehouse_in_apply fk_warehouse_in_apply_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in_apply
    ADD CONSTRAINT fk_warehouse_in_apply_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_warehouse_in_apply fk_warehouse_in_apply_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in_apply
    ADD CONSTRAINT fk_warehouse_in_apply_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.rf_warehouse(id);


--
-- Name: rf_warehouse_in_apply fk_warehouse_in_apply_warehouse_in; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in_apply
    ADD CONSTRAINT fk_warehouse_in_apply_warehouse_in FOREIGN KEY (warehouse_in_id) REFERENCES public.rf_warehouse_in(id);


--
-- Name: rf_warehouse_in fk_warehouse_in_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in
    ADD CONSTRAINT fk_warehouse_in_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_warehouse_in fk_warehouse_in_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in
    ADD CONSTRAINT fk_warehouse_in_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_warehouse_in fk_warehouse_in_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_in
    ADD CONSTRAINT fk_warehouse_in_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.rf_warehouse(id);


--
-- Name: rf_warehouse_out fk_warehouse_out_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_out
    ADD CONSTRAINT fk_warehouse_out_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_warehouse_out fk_warehouse_out_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_out
    ADD CONSTRAINT fk_warehouse_out_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_warehouse_out fk_warehouse_out_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_out
    ADD CONSTRAINT fk_warehouse_out_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.rf_warehouse(id);


--
-- Name: rf_product_warehouse_shipment fk_warehouse_shipment_internal_logistics; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_warehouse_shipment
    ADD CONSTRAINT fk_warehouse_shipment_internal_logistics FOREIGN KEY (internal_logistics_task_id) REFERENCES public.rf_internal_logistics_task(id);


--
-- Name: rf_product_warehouse_shipment fk_warehouse_shipment_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_warehouse_shipment
    ADD CONSTRAINT fk_warehouse_shipment_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_product_warehouse_shipment fk_warehouse_shipment_sell_record; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_warehouse_shipment
    ADD CONSTRAINT fk_warehouse_shipment_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES public.rf_product_sell_record(id);


--
-- Name: rf_product_warehouse_shipment fk_warehouse_shipment_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_product_warehouse_shipment
    ADD CONSTRAINT fk_warehouse_shipment_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.rf_warehouse(id);


--
-- Name: rf_warehouse_stock fk_warehouse_stock_in; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock
    ADD CONSTRAINT fk_warehouse_stock_in FOREIGN KEY (warehouse_in_id) REFERENCES public.rf_warehouse_in(id);


--
-- Name: rf_warehouse_stock fk_warehouse_stock_in_apply; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock
    ADD CONSTRAINT fk_warehouse_stock_in_apply FOREIGN KEY (warehouse_in_apply_id) REFERENCES public.rf_warehouse_in_apply(id);


--
-- Name: rf_warehouse_stock fk_warehouse_stock_out; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock
    ADD CONSTRAINT fk_warehouse_stock_out FOREIGN KEY (warehouse_out_id) REFERENCES public.rf_warehouse_out(id);


--
-- Name: rf_warehouse_stock fk_warehouse_stock_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock
    ADD CONSTRAINT fk_warehouse_stock_product FOREIGN KEY (product_id) REFERENCES public.rf_product(id);


--
-- Name: rf_warehouse_stock fk_warehouse_stock_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rf_warehouse_stock
    ADD CONSTRAINT fk_warehouse_stock_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.rf_warehouse(id);


--
-- Name: sys_role_menu sys_role_menu_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role_menu
    ADD CONSTRAINT sys_role_menu_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.sys_menu(id);


--
-- Name: sys_role_menu sys_role_menu_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_role_menu
    ADD CONSTRAINT sys_role_menu_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.sys_role(id);


--
-- Name: sys_user sys_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.sys_role(id);


--
-- Name: sys_user_stripe_account sys_user_stripe_account_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_user_stripe_account
    ADD CONSTRAINT sys_user_stripe_account_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.sys_user(id);


--
-- PostgreSQL database dump complete
--

